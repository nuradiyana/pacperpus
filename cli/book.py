import os
import random

import kagglehub
import dotenv
import pandas as pd
import numpy as np
from pandas.core.interchange.dataframe_protocol import DataFrame
from sqlalchemy import create_engine, text

dotenv.load_dotenv()

username = os.getenv('DB_USER')
password = os.getenv('DB_PASSWORD')
host = os.getenv('DB_HOST')
database = os.getenv('DB_NAME')
search_path = os.getenv('POSTGRES_SEARCH_PATH')

engine = create_engine(
    'postgresql://' + username + ':' + password + '@' + host + ':5432/' + database + '?options=-csearch_path=' + search_path
)


def generate_isbn():
    return f"{random.randint(100, 999)}-{random.randint(1000, 9999)}-{random.randint(100, 999)}-{random.randint(0, 9)}"


def truncate_table(table_name: str):
    with engine.connect() as connection:
        connection.execute(text(f'TRUNCATE TABLE {table_name} RESTART IDENTITY CASCADE'))
        connection.commit()
        print(f"Table {table_name} truncated.")


def download_dataset():
    dataset_path = kagglehub.dataset_download("elvinrustam/books-dataset")

    print("Path to dataset files:", dataset_path)

    return dataset_path


def extract_authors(path_dataset: str):
    print("Extracting authors...")

    raw = pd.read_csv(path_dataset + "/BooksDatasetClean.csv")

    df = raw[["Authors"]].copy()
    df = df[df["Authors"].str.len() <= 150]
    df.rename(columns={"Authors": "name"}, inplace=True)
    df.drop_duplicates(subset="name", inplace=True)
    df.dropna(inplace=True)

    truncate_table("authors")

    df.to_sql("authors", engine, if_exists="append", index=False)
    print("Extracted authors...")


def extract_categories(path_dataset: str):
    print("Extracting categories...")

    raw = pd.read_csv(path_dataset + "/BooksDatasetClean.csv")
    raw['Category'] = raw['Category'].str.split(',')
    raw = raw.explode('Category')

    df = raw[["Category"]].copy()
    df['Category'] = df['Category'].str.strip()
    df.rename(columns={"Category": "name"}, inplace=True)
    df.drop_duplicates(subset="name", inplace=True)
    df.dropna(inplace=True)

    truncate_table("categories")

    df.to_sql("categories", engine, if_exists="append", index=False)
    print("Extracted categories...")


def extract_publishers(path_dataset: str):
    print("Extracting publishers...")

    raw = pd.read_csv(path_dataset + "/BooksDatasetClean.csv")

    df = raw[["Publisher"]].copy()

    df.rename(columns={"Publisher": "name"}, inplace=True)
    df.drop_duplicates(subset="name", inplace=True)
    df.dropna(inplace=True)

    truncate_table("publishers")

    df.to_sql("publishers", engine, if_exists="append", index=False)
    print("Extracted publishers...")


def extract_books(path_dataset: str):
    print("Extracting books...")

    raw = pd.read_csv(path_dataset + "/BooksDatasetClean.csv")

    book_df = raw[["Title", "Description", "Publish Date (Year)"]].copy()
    book_df = book_df[book_df["Title"].str.len() <= 255]

    book_df.rename(columns={"Title": "title", "Description": "synopsis", "Publish Date (Year)": "publish_year"},
              inplace=True)
    book_df['author_id'] = np.random.randint(1, 60000, size=len(book_df))
    book_df['publisher_id'] = np.random.randint(1, 13000, size=len(book_df))
    book_df['isbn'] = [generate_isbn() for _ in range(len(book_df))]
    book_df['status'] = 'active'

    book_category_df = pd.DataFrame(columns=['book_id', 'category_id'])
    book_category_df['book_id'] = np.random.randint(1, 100000, size=len(book_df))
    book_category_df['category_id'] = np.random.randint(1, 2000, size=len(book_df))

    truncate_table("books")
    truncate_table('book_category')

    book_df.to_sql("books", engine, if_exists="append", index=False)
    book_category_df.to_sql("book_category", engine, if_exists="append", index=False)
    print("Extracted books...")


path = download_dataset()

extract_categories(path)
extract_publishers(path)
extract_authors(path)
extract_books(path)
