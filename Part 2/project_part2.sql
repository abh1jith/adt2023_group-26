USE adt_project;

-- Note: A slight machine configuration is needed to load the dataset inorder 
-- to insert the values into the tables. We have written the code for the value
-- insertion. If it doesn't work for you because of the reason mentioned, please
-- use the import wizard method to insert the values (We've uploaded the dataset
-- files in our github link).

-- Creating Table for Books- Abhijith Dameruppala(adameru@iu.edu)
CREATE TABLE books (
    bookID INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    authors VARCHAR(255),
    num_pages INT,
    publisher VARCHAR(255)
);

-- Loading data from csv into the table -- Viswa Suhas Penugonda (vpenugon@iu.edu)
LOAD DATA LOCAL INFILE '/Users/suhaaspenugonda/Desktop/books.csv' INTO TABLE books
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating Table for Ratings- Viswa Suhas Penugonda (vpenugon@iu.edu)
DROP TABLE ratings;
CREATE TABLE ratings (
	ratingID INT NOT NULL AUTO_INCREMENT,
    bookID INT,
    average_rating DECIMAL(3, 2),
    ratings_count INT,
    PRIMARY KEY (ratingID)
);

-- Loading data from csv into the table -- Viswa Suhas Penugonda (vpenugon@iu.edu)
LOAD DATA INFILE '/Users/suhaaspenugonda/Desktop/ratings.csv' INTO TABLE ratings
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating Table for isbn numbers- Fhariya Aseem Fathima (fha@iu.edu)
DROP TABLE isbn;
CREATE TABLE isbn(
	isbn VARCHAR(50),
    isbn13 VARCHAR(50),
    bookID INT,
    PRIMARY KEY (isbn)
);

-- Loading data from csv into the table -- Viswa Suhas Penugonda (vpenugon@iu.edu)
LOAD DATA INFILE '/Users/suhaaspenugonda/Desktop/isbn.csv' INTO TABLE isbn
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating Foreign key relations - Viswa Suhas Penugonda (vpenugon@iu.edu)
ALTER TABLE ratings
ADD FOREIGN KEY (bookID) REFERENCES books(bookID);

-- Adding a new column to remove the average_rating and ratings_count columns - Viswa Suhas Penugonda (vpenugon@iu.edu)
ALTER TABLE books
ADD COLUMN ratingID INT;

-- Creating Foreign key relations - Viswa Suhas Penugonda (vpenugon@iu.edu)
ALTER TABLE books
ADD FOREIGN KEY (ratingID) REFERENCES ratings(ratingID);

-- Populating the newly created column with the ratingIDs from the ratings table - Viswa Suhas Penugonda (vpenugon@iu.edu)
UPDATE books
JOIN ratings ON books.bookID = ratings.bookID
SET books.ratingID = ratings.ratingID
WHERE books.bookID IS NOT NULL;

-- Creating Foreign key relations - Fhariya Aseem Fathima (fha@iu.edu)
ALTER TABLE isbn
ADD FOREIGN KEY (bookID) REFERENCES books(bookID);


-- Performing Normalization on the database. -Abhijith Dameruppala (adameru@iu.edu)
-- Creating a new table to reduce duplicate data in the books table. This table reduces redundency, and organizes the table more. -Abhijith Dameruppala (adameru@iu.edu)
CREATE TABLE authors (
	authorID INT NOT NULL AUTO_INCREMENT,
    authorName VARCHAR(255),
    PRIMARY KEY (authorID)
);

-- Loading data from csv into the table -- Viswa Suhas Penugonda (vpenugon@iu.edu)
LOAD DATA INFILE '/Users/suhaaspenugonda/Desktop/authors.csv' INTO TABLE authors
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating a new column in the books table to reference authors table -Abhijith Dameruppala (adameru@iu.edu)
ALTER TABLE books
ADD COLUMN authorID INT;

-- Adding the foreign key relationship between these tables -Abhijith Dameruppala (adameru@iu.edu)
ALTER TABLE books
ADD FOREIGN KEY (authorID) REFERENCES authors(authorID);

-- Populating the books table with the distinct author names -Abhijith Dameruppala (adameru@iu.edu)
INSERT INTO authors (authorName)
SELECT DISTINCT authors
FROM books
WHERE authors IS NOT NULL AND authors != '';

-- Populating the newly created column from the books table with the authorIDs -Abhijith Dameruppala (adameru@iu.edu)
UPDATE books
JOIN authors ON books.authors = authors.authorName
SET books.authorID = authors.authorID
WHERE books.authors IS NOT NULL;

-- Now that we have successfully linked these tables, we delete the table. -Abhijith Dameruppala (adameru@iu.edu)
ALTER TABLE books
DROP COLUMN authors;


-- Checking the complete database for any anamolies -Fhariya Aseem Fathima (fha@iu.edu)
SELECT COUNT(*) FROM books;
SELECT * FROM books;

-- Checking the complete database for any anamolies -Fhariya Aseem Fathima (fha@iu.edu)
SELECT COUNT(*) FROM ratings;
SELECT * FROM ratings;

-- Checking the complete database for any anamolies -FFhariya Aseem Fathima (fha@iu.edu)
SELECT COUNT(*) FROM isbn;
SELECT * FROM isbn;

-- Checking the complete database for any anamolies -Fhariya Aseem Fathima (fha@iu.edu)
SELECT COUNT(*) FROM authors;
SELECT * FROM authors;

-- We can display the overall dataset with this query -Fhariya Aseem Fathima (fha@iu.edu)
SELECT b.bookID, b.title, a.authorID, a.authorName, b.num_pages, b.publisher, r.ratingID, r.average_rating, r.ratings_count, i.isbn, i.isbn13
FROM books b, ratings r, isbn i, authors a
WHERE b.ratingID = r.ratingID AND i.bookID = b.bookID AND b.authorID = a.authorID;
-- (575 rows, 11 columns)

-- Here are views that I created which returns all the books sorted in descending order or asending order of ratings - Abhijith Dameruppala(adameru@iu.edu)
CREATE VIEW BooksDesc AS
SELECT b.bookID, b.title, r.average_rating
FROM books b, ratings r 
WHERE b.bookID = r.bookID
ORDER BY r.average_rating DESC;

--  Fhariya Aseem Fathima (fha@iu.edu)
CREATE VIEW BooksAsc AS
SELECT b.bookID, b.title, r.average_rating
FROM books b, ratings r 
WHERE b.bookID = r.bookID
ORDER BY r.average_rating ASC;

-- We can also use these views by filtering the books such that they are above a certain rating, and then sorting them in asc, or desc. - Abhijith Dameruppala(adameru@iu.edu)
SELECT * 
FROM BooksDesc 
WHERE average_rating > 4.5;

-- Here are views that I created which returns all the books sorted in descending order or asending order of number of pages - Viswa Suhas Penugonda (vpenugon@iu.edu)
CREATE VIEW BookSizeDesc AS
SELECT b.bookID, b.title, r.average_rating, b.num_pages
FROM books b, ratings r 
WHERE b.bookID = r.bookID
ORDER BY b.num_pages DESC;

-- Viswa Suhas Penugonda (vpenugon@iu.edu)
CREATE VIEW BookSizeAsc AS
SELECT b.bookID, b.title, r.average_rating, b.num_pages
FROM books b, ratings r 
WHERE b.bookID = r.bookID
ORDER BY b.num_pages ASC;
