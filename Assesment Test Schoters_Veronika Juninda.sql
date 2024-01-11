CREATE DATABASE schoters; 

-------------- TABLE -------------
CREATE TABLE campaign (
	nama VARCHAR(100),
    startt VARCHAR(50),
    endd VARCHAR(50),
	budget_campaign VARCHAR(200),
    PRIMARY KEY (nama)
);
CREATE TABLE customer (
	nama VARCHAR(100), 
    domisili VARCHAR(300),
	usia INT,
    PRIMARY KEY (nama)
);
CREATE TABLE transaksi (
	tanggal VARCHAR(50),
    nama_sales VARCHAR(50),
    harga_asli VARCHAR(200) NULL,
    nama VARCHAR(50),
    tipe_produk VARCHAR(50),
    FOREIGN KEY (nama) REFERENCES customer(nama)
);
CREATE TABLE total_cust (
  nama VARCHAR(50),
  jumlah_transaksi INT,
  total INT,
  FOREIGN KEY (nama) REFERENCES transaksi(nama)
);
CREATE TABLE total_kota (
  nama_kota VARCHAR(200),
  jumlah_transaksi INT,
  total BIGINT
);

-- Konfigurasi secure_file_priv
SHOW VARIABLES LIKE "secure_file_priv";
SHOW VARIABLES LIKE "local_infile";
SET GLOBAL local_infile = 1;

-- Input data ke Tabel
-- LOAD Data Customer
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Customer-Grid view.csv'
INTO TABLE customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- LOAD Data Campaign
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Campaign-Grid view.csv'
INTO TABLE campaign
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- LOAD Data Transaksi
LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Transaksi-Grid view.csv'
INTO TABLE transaksi
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- UPDATE DATA
UPDATE transaksi 
SET harga_asli = REPLACE(harga_asli, 'Rp', '');
UPDATE transaksi
SET harga_asli = CAST(REPLACE(harga_asli, '.00', '') AS UNSIGNED) 
WHERE harga_asli LIKE '%.%';
SELECT harga_asli FROM transaksi;
UPDATE campaign
SET budget_campaign = REPLACE(budget_campaign, 'Rp', '');
UPDATE campaign
SET budget_campaign = CAST(REPLACE(budget_campaign, '.00', '') AS UNSIGNED) 
WHERE budget_campaign LIKE '%.%';
SELECT budget_campaign FROM campaign;

-- Data Total Transaksi Berdasarkan Customer
INSERT INTO total_cust (nama, jumlah_transaksi, total)
SELECT nama, COUNT(*), SUM(harga_asli)
FROM transaksi
GROUP BY nama;
SELECT * FROM total_cust;

-- Data Total Transaksi Berdasarkan Kota
INSERT INTO total_kota (nama_kota, jumlah_transaksi, total)
SELECT domisili, COUNT(*), SUM(harga_asli)
FROM transaksi
INNER JOIN customer ON transaksi.nama = customer.nama
GROUP BY domisili ORDER BY domisili;
SELECT * FROM total_kota;

-- Menampilkan Tabel
SELECT * FROM campaign;
SELECT * FROM customer;
SELECT * FROM transaksi;
-- Total transaksi dari masing-masing customer
SELECT * FROM total_cust;
-- Total transaksi dari masing-masing kota
SELECT * FROM total_kota;

-- Data total transaksi
-- Data max, min, dan average price
SELECT 
    COUNT(*) AS total_transactions,
    MAX(harga_asli) AS max_price,
    MIN(harga_asli) AS min_price,
    AVG(harga_asli) AS avg_price
FROM transaksi;

-- Analyze sales by salesperson and customer
SELECT 
    c.nama AS nama, 
    t.nama_sales, 
    SUM(t.harga_asli) AS total_sales 
FROM transaksi t 
JOIN customer c ON t.nama = c.nama 
GROUP BY t.nama_sales, c.nama ORDER BY c.nama;

-- Total sales for each salesperson in descending order
SELECT 
    t.nama_sales,
    COUNT(*) AS total_transactions,
    SUM(t.harga_asli) AS total_sales
FROM transaksi t
GROUP BY t.nama_sales
ORDER BY total_sales DESC;

-- Total sales for each customer in descending order
SELECT 
    c.nama, 
    SUM(t.harga_asli) AS total_sales
FROM transaksi t 
JOIN customer c ON t.nama = c.nama 
GROUP BY c.nama 
ORDER BY total_sales DESC;

-- Total transactions for each product in descending order
SELECT 
    t.tipe_produk, 
    COUNT(*) AS total_transactions
FROM Transaksi t 
GROUP BY t.tipe_produk 
ORDER BY total_transactions DESC;

SELECT SUM(harga_asli) AS total_pendapatan_company FROM transaksi;
SELECT SUM(budget_campaign) AS total_pengeluaran_company FROM campaign;