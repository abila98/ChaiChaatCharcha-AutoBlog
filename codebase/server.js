const express = require('express');
const multer = require('multer');
const multerS3 = require('multer-s3');
const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3');
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand, ScanCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(express.static('public'));

const REGION = process.env.AWS_REGION || 'us-east-1';
const BUCKET = process.env.S3_BUCKET;
const TABLE = process.env.DYNAMO_TABLE || 'ccc-entries';

const s3 = new S3Client({ region: REGION });
const dynamo = DynamoDBDocumentClient.from(new DynamoDBClient({ region: REGION }));

const upload = multer({
  storage: multerS3({
    s3,
    bucket: BUCKET,
    key: (req, file, cb) => cb(null, `images/${uuidv4()}-${file.originalname}`)
  })
});

// Get all entries
app.get('/api/entries', async (req, res) => {
  try {
    const result = await dynamo.send(new ScanCommand({ TableName: TABLE }));
    const entries = await Promise.all(result.Items.map(async (item) => {
      const url = await getSignedUrl(s3, new GetObjectCommand({ Bucket: BUCKET, Key: item.imageKey }), { expiresIn: 3600 });
      return { ...item, imageUrl: url };
    }));
    entries.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    res.json(entries);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch entries' });
  }
});

// Create entry
app.post('/api/entries', upload.single('image'), async (req, res) => {
  try {
    const { title, review, rating, location } = req.body;
    const entryId = uuidv4();
    const imageKey = req.file.key;
    const entry = {
      entryId,
      title,
      review,
      rating: Number(rating),
      location,
      imageKey,
      createdAt: new Date().toISOString()
    };
    await dynamo.send(new PutCommand({ TableName: TABLE, Item: entry }));
    res.json({ success: true, entryId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create entry' });
  }
});

// Delete entry
app.delete('/api/entries/:id', async (req, res) => {
  try {
    await dynamo.send(new DeleteCommand({ TableName: TABLE, Key: { entryId: req.params.id } }));
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete entry' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`StreetSip running on port ${PORT}`));