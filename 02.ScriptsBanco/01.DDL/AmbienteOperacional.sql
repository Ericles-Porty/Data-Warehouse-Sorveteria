CREATE DATABASE REDE_SORVETERIA
USE REDE_SORVETERIA

-- CREATING TABLES
CREATE TABLE TB_VENDA(
	ID INT NOT NULL PRIMARY KEY,
	ID_ESTABELECIMENTO INT NOT NULL,
	VALOR DECIMAL(10, 2) NOT NULL,
	DATA_VENDA DATETIME NOT NULL
)

CREATE TABLE TB_ITEM(
	ID INT NOT NULL PRIMARY KEY,
	ID_SABOR INT NULL,
	ID_PRODUTO INT NOT NULL,
	ID_VENDA INT NOT NULL,
	VALOR DECIMAL(10, 2) NOT NULL
)

CREATE TABLE TB_ESTABELECIMENTO(
	ID INT NOT NULL PRIMARY KEY,
	ID_LOCAL INT NOT NULL,
	NOME VARCHAR(100) NOT NULL,
	CNPJ VARCHAR(14) NULL,
)

CREATE TABLE TB_LOCAL(
	ID INT NOT NULL PRIMARY KEY,
	ESTADO CHAR(2) NOT NULL,
	CIDADE VARCHAR(50) NOT NULL,
	BAIRRO VARCHAR(50) NULL,
	RUA VARCHAR(50) NULL,
	NUMERO VARCHAR(6) NULL
)

CREATE TABLE TB_PRODUTO(
	ID INT NOT NULL PRIMARY KEY,
	PRODUTO VARCHAR(50) NOT NULL,
	VALOR DECIMAL(10, 2) NOT NULL,
)

CREATE TABLE TB_SABOR(
	ID INT NOT NULL PRIMARY KEY,
	SABOR VARCHAR(50) NOT NULL
)

CREATE TABLE TB_ADICIONAL(
	ID INT NOT NULL PRIMARY KEY,
	ADICIONAL VARCHAR(50) NOT NULL,
	VALOR DECIMAL(10, 2) NOT NULL
)

CREATE TABLE TB_ITEM_ADICIONAL(
	ID_ADICIONAL INT NOT NULL,
	ID_ITEM INT NOT NULL
)

-- REFERENTIAL INTEGRITY
ALTER TABLE TB_VENDA
ADD CONSTRAINT FK_VENDA_ESTABELECIMENTO
FOREIGN KEY(ID_ESTABELECIMENTO) REFERENCES TB_ESTABELECIMENTO(ID)

ALTER TABLE TB_ESTABELECIMENTO
ADD CONSTRAINT FK_ESTABELECIMENTO_LOCAL
FOREIGN KEY(ID_LOCAL) REFERENCES TB_LOCAL(ID)

ALTER TABLE TB_ITEM_ADICIONAL
ADD CONSTRAINT FK_ITEM_ADICIONAL
FOREIGN KEY(ID_ADICIONAL) REFERENCES TB_ADICIONAL(ID)

ALTER TABLE TB_ITEM_ADICIONAL
ADD CONSTRAINT FK_ADICIONAL_ITEM
FOREIGN KEY(ID_ITEM) REFERENCES TB_ITEM(ID)

ALTER TABLE TB_ITEM
ADD CONSTRAINT FK_ITEM_SABOR
FOREIGN KEY(ID_SABOR) REFERENCES TB_SABOR(ID)

ALTER TABLE TB_ITEM
ADD CONSTRAINT FK_ITEM_PRODUTO
FOREIGN KEY(ID_PRODUTO) REFERENCES TB_PRODUTO(ID)

ALTER TABLE TB_ITEM
ADD CONSTRAINT FK_ITEM_VENDA
FOREIGN KEY(ID_VENDA) REFERENCES TB_VENDA(ID)

-- INSERTING DATA
INSERT INTO TB_LOCAL(ID, ESTADO, CIDADE, BAIRRO, RUA, NUMERO)
VALUES  (1, 'SE', 'CARIRA', 'CENTRO', 'RUA A', 575),
		(2, 'SE', 'ITABAIANA', 'CENTRO', 'RUA B', 300),
		(3, 'SE', 'ARACAJU', 'CENTRO', 'RUA C', 1755),
		(4, 'SP', 'SÃO PAULO', 'CENTRO', 'RUA D', 2505),
		(5, 'RJ', 'RIO DE JANEIRO', 'CENTRO', 'RUA E', 4075),
		(6, 'SP', 'SÃO JOSÉ DOS CAMPOS', 'CENTRO', 'RUA F', 605),
		(7, 'RJ', 'IPANEMA', 'CENTRO', 'RUA G', 632),
		(8, 'BA', 'SALVADOR', 'CENTRO', 'RUA H', 958),
		(9, 'PA', 'BELEM', 'CENTRO', 'RUA I', 1065),
		(10, 'RN', 'NATAL', 'CENTRO', 'RUA J', 871)

INSERT INTO TB_ESTABELECIMENTO(ID, ID_LOCAL, NOME, CNPJ)
VALUES	(1, 1, 'MANIA', '12345679'),
		(2, 2, 'CASQUITA', '12345679'),
		(3, 2, 'BOBS', '12345679'),
		(4, 3, 'BOBS', '12345679'),
		(5, 4, 'BOBS', '12345679'),
		(6, 5, 'BOBS', '12345679'),
		(7, 6, 'BOBS', '12345679'),
		(8, 7, 'BOBS', '12345679'),
		(9, 8, 'BOBS', '12345679'),
		(10, 9, 'BOBS', '12345679'),
		(11, 10, 'BOBS', '12345679'),
		(12, 2, 'GIRAFAS', '12345679'),
		(13, 3, 'GIRAFAS', '12345679'),
		(14, 4, 'GIRAFAS', '12345679'),
		(15, 5, 'GIRAFAS', '12345679'),
		(16, 6, 'GIRAFAS', '12345679'),
		(17, 7, 'GIRAFAS', '12345679'),
		(18, 8, 'GIRAFAS', '12345679'),
		(19, 9, 'GIRAFAS', '12345679'),
		(20, 10, 'GIRAFAS', '12345679')

INSERT INTO TB_PRODUTO(ID, PRODUTO, VALOR)
VALUES	(1, 'PICOLÉ', 3), 
		(2, 'BOLA DE SORVETE', 4.50), 
		(3, 'SUNDAE', 10), 
		(4, 'AÇAÍ P', 12), 
		(5, 'AÇAÍ M', 15), 
		(6, 'AÇAÍ G', 18) 

INSERT INTO TB_SABOR(ID, SABOR)
VALUES	(1, 'CHOCOLATE'), 
		(2, 'MORANGO'), 
		(3, 'NAPOLITANO'), 
		(4, 'FLOCOS'), 
		(5, 'CREME'), 
		(6, 'COCO'), 
		(7, 'CAFÉ'), 
		(8, 'MARACUJÁ'), 
		(9, 'AÇAÍ'), 
		(10, 'CASTANHA')

INSERT INTO TB_ADICIONAL(ID, ADICIONAL, VALOR)
VALUES  (1, 'LEITE EM PÓ', 1.0), 
		(2, 'DISCKET', 1.0), 
		(3, 'AMENDOIM', 1.0), 
		(4, 'OVOMALTINE', 1.0), 
		(5, 'BANANA', 1.0), 
		(6, 'LEITE CONDENSADO', 1.0), 
		(7, 'MORANGO', 1.0), 
		(8, 'KIWI', 1.0), 
		(9, 'RASPAS DE CHOCOLATE', 1.0), 
		(10, 'CHANTILY', 1.0)

SELECT * FROM TB_VENDA V
LEFT JOIN TB_ITEM I ON(I.ID = V.ID)
JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)

SELECT MONTH(V.DATA_VENDA), COUNT(I.ID), SUM(V.VALOR) FROM TB_VENDA V
LEFT JOIN TB_ITEM I ON(I.ID = V.ID)
JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)
GROUP BY MONTH(V.DATA_VENDA)

DELETE TB_ITEM
/*
INSERT INTO TB_VENDA(ID, ID_ESTABELECIMENTO, DATA, VALOR)
VALUES	(1, 1, 3.0, '2022-11-03'),
		(2, 1, 3.0, '2022-11-03'),
		(3, 2, 4.5, '2022-11-03'),
		(4, 2, 4.5, '2022-11-03'),
		(5, 2, 4.5, '2022-11-03'),
		(6, 3, 10.0, '2022-11-03'),
		(7, 4, 10.0, '2022-11-03'),
		(8, 5, 13.0, '2022-11-03'),
		(9, 5, 6.0, '2022-11-03'),
		(10, 6, 29.0, '2022-11-03'),
		(11, 7, 17.5, '2022-11-03'),
		(12, 8, 24.5, '2022-11-03'),
		(13, 9, 29, '2022-11-03')
		
INSERT INTO TB_ITEM(ID, ID_SABOR, ID_PRODUTO, ID_VENDA, VALOR)
VALUES	(1, 1, 1, 1, 3.0),
		(2, 1, 1, 2, 3.0),
		(3, 1, 2, 3, 4.5),
		(4, 2, 2, 4, 4.5),
		(5, 2, 2, 5, 4.5),
		(6, 2, 3, 6, 10.0),
		(7, 2, 3, 7, 10.0),
		(8, 3, 3, 8, 10.0),
		(9, 3, 1, 8, 3.0),
		(10, 4, 1, 9, 3.0),
		(11, 4, 1, 9, 3.0),
		(12, 4, 2, 10, 4.5),
		(13, 5, 2, 10, 4.5),
		(14, 5, 3, 10, 10.0),
		(15, 6, 3, 10, 10.0),
		(16, 6, 2, 11, 4.5),
		(17, 7, 3, 11, 10.0),
		(18, 7, 1, 11, 3.0),
		(19, 7, 3, 12, 10.0),
		(20, 8, 2, 12, 4.5),
		(21, 8, 3, 12, 10.0),
		(22, 9, 2, 13, 4.5),
		(23, 9, 3, 13, 10.0),
		(24, 10, 3, 13, 10.0),
		(25, 10, 2, 13, 4.5)
*/