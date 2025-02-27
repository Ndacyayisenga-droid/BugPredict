const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const { MongoClient } = require('mongodb');

const app = express();

// MongoDB Atlas Connection URI (update credentials accordingly)
const mongoURI = 'mongodb+srv://noah:noah123@glitchdb.tp3kf.mongodb.net/?retryWrites=true&w=majority&appName=glitchdb';
const dbName = 'noah';


async function connectDB() {
    // Removed useUnifiedTopology if it's not supported; you might keep useNewUrlParser if needed.
    const client = new MongoClient(mongoURI, { useNewUrlParser: true });
    await client.connect();
    console.log('Connected to MongoDB Atlas');
    return client.db(dbName);
}

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'public')));

app.use((req, res, next) => {
    res.locals.result = null;
    next();
});

app.post('/getScore', async (req, res) => {
    try {
        const db = await connectDB();
        const result = await db.collection("testTable")
            .find({ File: req.body.file_name })
            .sort({ Date: -1 })
            .limit(5)
            .toArray();

        res.render('score.ejs', {
            result: result,
            file_name: req.body.file_name
        });
    } catch (err) {
        console.error(err);
        res.status(500).send('Database error');
    }
});

app.get('/', async (req, res) => {
    try {
        const db = await connectDB();
        const result = await db.collection("testTable")
            .find({}, { projection: { File: 1, Score: 1, Date: 1, Commits: 1, _id: 0 } })
            .limit(10)
            .toArray();

        res.render('index', { result: result });
    } catch (err) {
        console.error(err);
        res.status(500).send('Database error');
    }
});

app.listen(3000, () => {
    console.log("Server Started on Port 3000 .... ");
});
