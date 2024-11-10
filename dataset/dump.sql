SET SEARCH_PATH TO pacperpus;

/*
 * Name : employees
 * Description : This table stores the information of the employees.
 */
CREATE TABLE IF NOT EXISTS employees
(
    id                    SERIAL PRIMARY KEY,
    number                VARCHAR(32)  NOT NULL UNIQUE,
    name                  VARCHAR(150) NOT NULL,
    email                 VARCHAR(255) NOT NULL UNIQUE,
    address               VARCHAR(255) NOT NULL,
    postal_code           VARCHAR(15)  NOT NULL,
    identification_type   VARCHAR(50)  NOT NULL,
    identification_number VARCHAR(100) NOT NULL UNIQUE,
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON COLUMN employees.number IS 'This is the unique number of the employee.';
COMMENT ON COLUMN employees.identification_type IS 'This is the type of identification of the employee, ex: KTP, KTM< SIM, PASSPORT.';
COMMENT ON COLUMN employees.identification_number IS 'This is the number of the identification of the employee.';

/*
 * Name : members
 * Description : This table stores the information of the members.
 */
CREATE TABLE IF NOT EXISTS members
(
    id                    SERIAL PRIMARY KEY,
    number                VARCHAR(32)  NOT NULL UNIQUE,
    name                  VARCHAR(150) NOT NULL,
    email                 VARCHAR(255) NOT NULL UNIQUE,
    address               VARCHAR(255) NOT NULL,
    postal_code           VARCHAR(15)  NOT NULL,
    identification_type   VARCHAR(50)  NOT NULL,
    identification_number VARCHAR(100) NOT NULL UNIQUE,
    longitude             FLOAT        NULL,
    latitude              FLOAT        NULL,
    registered_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    registered_library_id INT          NULL CHECK ( registered_library_id > 0 ),
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON COLUMN members.number IS 'This is the unique number of the member.';
COMMENT ON COLUMN members.identification_type IS 'This is the type of identification of the member, ex: KTP, KTM< SIM, PASSPORT.';
COMMENT ON COLUMN members.identification_number IS 'This is the number of the identification of the member.';
COMMENT ON COLUMN members.longitude IS 'This is the longitude of the member address, useful for distance calculation with library';
COMMENT ON COLUMN members.latitude IS 'This is the latitude of the member address, useful for distance calculation with library.';
COMMENT ON COLUMN members.registered_library_id IS 'This is the library where the member is registered, can null if online registration.';

/*
 * Name : users
 * Description : This table stores the information of the users.
 */
CREATE TABLE IF NOT EXISTS users
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    member_id   INT          NULL CHECK ( member_id > 0 ),
    employee_id INT          NULL CHECK ( employee_id > 0 ),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE SET NULL ON UPDATE CASCADE
);

/*
 * Name : libraries
 * Description : This table stores the information of the libraries.
 */
CREATE TABLE IF NOT EXISTS libraries
(
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(32)  NOT NULL UNIQUE,
    name        VARCHAR(150) NOT NULL,
    address     VARCHAR(255) NOT NULL,
    postal_code VARCHAR(15)  NOT NULL,
    phone       VARCHAR(25)  NULL,
    longitude   FLOAT        NULL,
    latitude    FLOAT        NULL,
    manager_id  INT          NOT NULL CHECK ( manager_id > 0 ),
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES employees (id) ON DELETE SET NULL ON UPDATE CASCADE
);

COMMENT ON COLUMN libraries.code IS 'This is the unique code of the library.';
COMMENT ON COLUMN libraries.longitude IS 'This is the longitude of the library address, useful for distance calculation with member.';
COMMENT ON COLUMN libraries.latitude IS 'This is the latitude of the library address, useful for distance calculation with member.';
COMMENT ON COLUMN libraries.manager_id IS 'This is the manager of the library.';

/*
 * Name : employee_library
 * Description : This table stores the relationship (Many-To-Many) between employees and libraries.
 */
CREATE TABLE IF NOT EXISTS employee_library
(
    employee_id INT NOT NULL CHECK ( employee_id > 0 ),
    library_id  INT NOT NULL CHECK ( library_id > 0 ),
    FOREIGN KEY (employee_id) REFERENCES employees (id),
    FOREIGN KEY (library_id) REFERENCES libraries (id)
);

/*
 * Name : authors
 * Description : This table stores the information of the authors.
 */
CREATE TABLE IF NOT EXISTS authors
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    profile    TEXT         NULL,
    avatar     VARCHAR(255) NULL,
    is_active  BOOLEAN   DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
 * Name : categories
 * Description : This table stores the information of the categories.
 */
CREATE TABLE IF NOT EXISTS categories
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(150) NOT NULL,
    is_active  BOOLEAN   DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
 * Name : publisher
 * Description : This table stores the information of the publishers.
 */
CREATE TABLE IF NOT EXISTS publishers
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(150) NOT NULL,
    profile    TEXT         NULL,
    avatar     VARCHAR(255) NULL,
    is_active  BOOLEAN   DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
 * Name : collections
 * Description : This table stores the information of the collections.
 */
CREATE TABLE IF NOT EXISTS collections
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(150) NOT NULL,
    content    TEXT         NULL,
    is_active  BOOLEAN   DEFAULT TRUE,
    image_path VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
 * Name : books
 * Description : This table stores the information of the books.
 */
CREATE TABLE IF NOT EXISTS books
(
    id            SERIAL PRIMARY KEY,
    title         VARCHAR(150) NOT NULL,
    subtitle      VARCHAR(255) NULL,
    cover         VARCHAR(255) NULL,
    isbn          VARCHAR(17)  NOT NULL UNIQUE,
    author_id     INT          NOT NULL CHECK ( author_id > 0 ),
    synopsis      TEXT         NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    publish_year  INT          NULL,
    publisher_id  INT          NOT NULL CHECK ( publisher_id > 0 ),
    keywords      JSONB        NULL,
    status        VARCHAR(15)  NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors (id),
    FOREIGN KEY (publisher_id) REFERENCES publishers (id)
);
COMMENT ON COLUMN books.author_id IS 'This is the main author of the book, use author_book table for multiple authors / co-authors.';
COMMENT ON COLUMN books.keywords IS 'This is the keywords of the book, stored in JSONB format. ex: ["fiction", "novel", "fantasy"].';

/*
 * Name : book_placements
 * Description : This table stores the placement of the books in the library.
 */
CREATE TABLE IF NOT EXISTS book_placements
(
    id             SERIAL PRIMARY KEY,
    library_id     INT NOT NULL CHECK ( library_id > 0 ),
    book_id        INT NOT NULL CHECK ( book_id > 0 ),
    stock_quantity INT NOT NULL CHECK ( stock_quantity >= 0 ),
    real_quantity  INT NOT NULL CHECK ( real_quantity >= 0 ),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (library_id) REFERENCES libraries (id),
    FOREIGN KEY (book_id) REFERENCES books (id)
);

COMMENT ON COLUMN book_placements.stock_quantity IS 'This is the stock quantity of the book in the library.';
COMMENT ON COLUMN book_placements.real_quantity IS 'This is the real quantity of the book in the library, indicates the book that is available to borrow.';

/*
 * Name : book_category
 * Description : This table stores the relationship (Many-To-Many) between books and categories.
 */
CREATE TABLE IF NOT EXISTS book_category
(
    book_id     INT NOT NULL CHECK ( book_id > 0 ),
    category_id INT NOT NULL CHECK ( category_id > 0 ),
    FOREIGN KEY (book_id) REFERENCES books (id),
    FOREIGN KEY (category_id) REFERENCES categories (id)
);

/*
 * Name : book_collection
 * Description : This table stores the relationship (Many-To-Many) between books and collections.
 */
CREATE TABLE IF NOT EXISTS book_collection
(
    book_id       INT NOT NULL CHECK ( book_id > 0 ),
    collection_id INT NOT NULL CHECK ( collection_id > 0 ),
    FOREIGN KEY (book_id) REFERENCES books (id),
    FOREIGN KEY (collection_id) REFERENCES collections (id)
);

/*
 * Name : author_book
 * Description : This table stores the relationship (Many-To-Many) between co-authors and books.
 */
CREATE TABLE IF NOT EXISTS author_book
(
    author_id INT NOT NULL CHECK ( author_id > 0 ),
    book_id   INT NOT NULL CHECK ( book_id > 0 ),
    FOREIGN KEY (author_id) REFERENCES authors (id),
    FOREIGN KEY (book_id) REFERENCES books (id)
);

/*
 * Name : visitors
 * Description : This table stores the information of the member visitors.
 */
CREATE TABLE IF NOT EXISTS visitors
(
    id          SERIAL PRIMARY KEY,
    member_id   INT         NOT NULL CHECK ( member_id > 0 ),
    library_id  INT         NOT NULL CHECK ( library_id > 0 ),
    entering_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    leaving_at  TIMESTAMP   NULL     DEFAULT CURRENT_TIMESTAMP,
    locker      VARCHAR(10) NULL,
    created_at  TIMESTAMP            DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP            DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members (id),
    FOREIGN KEY (library_id) REFERENCES libraries (id)
);

/*
 * Name : loans
 * Description : This table stores the information of the book loans.
 */
CREATE TABLE IF NOT EXISTS loans
(
    id          SERIAL PRIMARY KEY,
    number      VARCHAR(32)    NOT NULL UNIQUE,
    member_id   INT            NOT NULL CHECK ( member_id > 0 ),
    library_id  INT            NOT NULL CHECK ( library_id > 0 ),
    borrowed_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_at      TIMESTAMP      NOT NULL,
    return_at   TIMESTAMP      NULL,
    fee         DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    created_at  TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP               DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members (id),
    FOREIGN KEY (library_id) REFERENCES libraries (id)
);

/*
 * Name : loan_items
 * Description : This table stores the items of the book loans.
 */
CREATE TABLE IF NOT EXISTS loan_items
(
    id         SERIAL PRIMARY KEY,
    loan_id    INT NOT NULL CHECK ( loan_id > 0 ),
    book_id    INT NOT NULL CHECK ( book_id > 0 ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES loans (id),
    FOREIGN KEY (book_id) REFERENCES books (id)
);

/*
 * Name : holds
 * Description : This table stores the information of the book holds.
 */
CREATE TABLE IF NOT EXISTS holds
(
    id         SERIAL PRIMARY KEY,
    number     VARCHAR(32) NOT NULL UNIQUE,
    member_id  INT         NOT NULL CHECK ( member_id > 0 ),
    library_id INT         NOT NULL CHECK ( library_id > 0 ),
    book_id    INT         NOT NULL CHECK ( book_id > 0 ),
    expired_at TIMESTAMP   NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books (id),
    FOREIGN KEY (member_id) REFERENCES members (id),
    FOREIGN KEY (library_id) REFERENCES libraries (id)
);

/*
 * Name : reviews
 * Description : This table stores the information of the book reviews.
 */
CREATE TABLE IF NOT EXISTS reviews
(
    id         SERIAL PRIMARY KEY,
    book_id    INT          NOT NULL CHECK ( book_id > 0 ),
    member_id  INT          NOT NULL CHECK ( member_id > 0 ),
    title      VARCHAR(255) NOT NULL,
    content    TEXT         NULL,
    rating     INT          NOT NULL CHECK ( rating >= 1 AND rating <= 5 ),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members (id),
    FOREIGN KEY (book_id) REFERENCES books (id)
);

/*
 * Name : favorites
 * Description : This table stores the information of the member book favorites.
 */
CREATE TABLE IF NOT EXISTS favorites
(
    member_id INT NOT NULL CHECK ( member_id > 0 ),
    book_id   INT NOT NULL CHECK ( book_id > 0 ),
    FOREIGN KEY (member_id) REFERENCES members (id),
    FOREIGN KEY (book_id) REFERENCES books (id)
);
