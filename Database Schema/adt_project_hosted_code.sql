use sql5668447;

CREATE TABLE books (
    bookID INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    authors VARCHAR(255),
    num_pages INT,
    publisher VARCHAR(255)
);


CREATE TABLE ratings (
	ratingID INT NOT NULL AUTO_INCREMENT,
    bookID INT,
    average_rating DECIMAL(3, 2),
    ratings_count INT,
    PRIMARY KEY (ratingID)
);

CREATE TABLE isbn(
	isbn VARCHAR(50),
    isbn13 VARCHAR(50),
    bookID INT,
    PRIMARY KEY (isbn)
);

ALTER TABLE ratings
ADD FOREIGN KEY (bookID) REFERENCES books(bookID);

ALTER TABLE books
ADD COLUMN ratingID INT;

SET SQL_SAFE_UPDATES = 0;
UPDATE books
JOIN ratings ON books.bookID = ratings.bookID
SET books.ratingID = ratings.ratingID
WHERE books.bookID IS NOT NULL;


ALTER TABLE isbn
ADD FOREIGN KEY (bookID) REFERENCES books(bookID);

SELECT * FROM books;
SELECT * FROM authors;
CREATE TABLE authors (
	authorID INT NOT NULL AUTO_INCREMENT,
    authorName VARCHAR(255),
    PRIMARY KEY (authorID)
);


-- 
SELECT CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'isbn' AND CONSTRAINT_TYPE = 'FOREIGN KEY';

ALTER TABLE ratings DROP FOREIGN KEY ratings_ibfk_1;
ALTER TABLE ratings DROP FOREIGN KEY ratings_ibfk_2;
ALTER TABLE isbn DROP FOREIGN KEY isbn_ibfk_1;

DROP TABLE books;

-- 
ALTER TABLE books
ADD COLUMN authorID INT;

ALTER TABLE books
ADD FOREIGN KEY (authorID) REFERENCES authors(authorID);

INSERT INTO authors (authorName)
SELECT DISTINCT authors
FROM books
WHERE authors IS NOT NULL AND authors != '';

UPDATE books
JOIN authors ON books.authors = authors.authorName
SET books.authorID = authors.authorID
WHERE books.authors IS NOT NULL;
SELECT * FROM books;



CREATE TABLE users (
	name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL PRIMARY KEY,
    password VARCHAR(255) NOT NULL
);
SELECT * FROM users;
CREATE TABLE reviews(userID VARCHAR (100) NOT NULL,
					 BookID INT,
					 rating DECIMAL,
					 reviewID INT PRIMARY KEY AUTO_INCREMENT,
					 review VARCHAR (300),
                     likes INT);
