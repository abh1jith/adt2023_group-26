require('dotenv').config();
const express = require("express");
const bodyParser = require("body-parser")
const mysql = require("mysql2");
const cors = require("cors");
const bcrypt = require('bcrypt');


const app = express();

app.use(cors());
app.use(bodyParser.json());

app.listen(process.env.PORT || 3001, () => {
    console.log("Server started at port 3001")
});


const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
});



app.get("/", (req, res)=>{
    res.send("Back end has been deployed successfully!");
})

app.get("/getAllBooks", (req, res) => {
    db.execute("SELECT b.bookID, b.title, a.authorName, b.num_pages, b.publisher, r.average_rating, r.ratings_count FROM books b, ratings r, isbn i, authors a WHERE b.ratingID = r.ratingID AND i.bookID = b.bookID AND b.authorID = a.authorID;", (err, result) =>{
        if(err) console.log(err);
        res.status(200).json(result);
    })
});

app.post("/getBook", (req, res) => {
    db.execute("SELECT b.bookID, b.title, a.authorName, b.num_pages, b.publisher, r.average_rating, r.ratings_count FROM books b, ratings r, isbn i, authors a WHERE b.ratingID = r.ratingID AND i.bookID = b.bookID AND b.authorID = a.authorID AND b.bookID = ?;", [req.body.bookID], (err, result) =>{
        if(err) console.log(err);
        console.log(result);
        res.status(200).json(result);
    })
});

app.post("/getReview", (req, res) => {
    db.execute("SELECT review, rating FROM reviews WHERE reviewID = ?", [req.body.reviewID], (err, result) =>{
        if(err) console.log(err);
        console.log(result);
        res.status(200).json(result);
    })
});

app.post("/createUser", function(req, res){
    bcrypt.hash(req.body.password, 10, function(err, hash) {
        db.execute("INSERT INTO users (name, email, password) VALUES (?, ?, ?);", [req.body.name, req.body.email, hash], (err, result) =>{
        if(err) {
            console.log(err);
            res.status(400).json({ error: "An account with this email already exists!" });
        }
        else{
            res.status(200).json({ message: "Account successfully created!\nPlease login." });
    }
})
    });
})

app.post("/loginUser", function(req, res){
    db.execute("SELECT name, password FROM users WHERE email = ?;", [req.body.email], (err, result) =>{
        if(err) console.log(err);
        else{
            if (result.length > 0) {
                bcrypt.compare(req.body.password, result[0].password, function(err, compare) {
                if(compare == true) res.status(200).json({ message: "User Authenticated", userName: result[0].name });
                else res.status(401).json({ error: "Failed to authenticate" });
            });
        }
            else{
                res.status(401).json({ error: "User Not found" });
            }
    }
    })

});

app.post("/addReview", (req, res) => {
    db.execute("SELECT average_rating, ratings_count FROM ratings WHERE bookID = ?", [req.body.bookID], (err, data) => {
        if(err) console.log(err);
        let avg_rat = data[0].average_rating
        let rat_count = data[0].ratings_count
        avg_rat = ((avg_rat * rat_count) + req.body.rating) / (rat_count + 1);
        rat_count += 1;
        db.execute("UPDATE ratings SET average_rating = ?, ratings_count = ? WHERE bookID = ?;", [avg_rat, rat_count, req.body.bookID], (err, response) => {
            if(err) console.log(err);
        })
    })

    db.execute("INSERT INTO reviews (userID, BookID, rating, review, likes) VALUES (?, ?, ?, ?, ?);", [req.body.userID, req.body.bookID, req.body.rating, req.body.review, req.body.likes], (err, result) => {
        if(err) console.log(err);
        else{
            res.status(200).json({data: result});
        }
    })
});

app.get("/getAllReviews", (req, res)=>{
    db.execute("SELECT b.bookID, re.rating, b.title, re.reviewID, re.userID, r.average_rating,  re.review, u.name, re.likes FROM books b, ratings r, reviews re, users u WHERE re.bookID = b.bookID AND re.bookID = r.bookID AND u.email = re.userID;", (err, response)=>{
        if(err) console.log(err);
        res.status(200).json(response);
    })
});

app.post("/getMyReviews", (req, res)=>{
    db.execute("SELECT b.bookID, b.title, re.rating, re.reviewID, re.userID, r.average_rating,  re.review, u.name, re.likes FROM books b, ratings r, reviews re, users u WHERE re.bookID = b.bookID AND re.bookID = r.bookID AND u.email = re.userID AND re.userID = ?;",[req.body.userID], (err, response)=>{
        if(err) console.log(err);
        res.status(200).json(response);
    })
});

app.post("/editReview", (req, res) => {
    db.execute("UPDATE reviews SET rating = ?, review = ? WHERE reviewID = ?;", [req.body.rating, req.body.review, req.body.reviewID], (err, response)=>{
        if(err) console.log(err);
        res.status(200).json({"message": "Review Updated!"});
    });
});

app.post("/deleteReview", (req, res) => {
    db.execute("DELETE FROM reviews WHERE reviewID = ?;", [req.body.reviewID], (err, response)=>{
        if(err) console.log(err);
        res.status(200).json({"message": "Review Deleted!"});
    });
});

app.post("/addLike", (req, res)=> {
    db.execute("UPDATE reviews SET likes = ? WHERE reviewID = ?;", [req.body.likesCount, req.body.reviewID], (err, response) => {
        if(err) console.log(err);
        res.status(200).json({"message": "Likes updated"});
    });
});