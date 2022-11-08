-- SEQUENCES TO GENERATE IDS FOR TABLE TB_ITEM AND TB_VENDA
CREATE SEQUENCE SQ_VENDA START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE SQ_ITEM START WITH 1 INCREMENT BY 1;

-- FUNCTION TO GENERATE RANDOM NUMBERS
GO
CREATE OR ALTER FUNCTION dbo.FN_ALEATORIO(@RAND FLOAT, @MAIOR_VALOR INT, @MENOR_VALOR INT =1)
RETURNS INT 
AS
BEGIN
    RETURN (SELECT FLOOR(@RAND*(@MAIOR_VALOR-@MENOR_VALOR+1))+@MENOR_VALOR);
END

-- PROCEDURE TO POPULATE TABLE TB_ITEM FOR A TB_VENDA
GO
CREATE OR ALTER PROCEDURE SP_INSERT_ITEM_PRODUTO(@DATA datetime, @CATEGORIA VARCHAR(100))
AS
BEGIN
	SET nocount on
    DECLARE @ID_SABOR INT,
	        @ID_PRODUTO INT,
	        @ID_VENDA INT,
	        @ID_ADICIONAL INT,
	        @ID_LOCAL INT,
	        @ID_ESTABELECIMENTO INT,
	        @VALOR NUMERIC(10, 2),
			@TOTAL_ITENS INT,
			@CONTADOR_ITENS INT = 0,
			@CONTADOR_ADICIONAIS INT = 0,
			@VALOR_TOTAL NUMERIC(10, 2),
			@ID_ITEM INT,
			@QUANTIDADE_ADICIONAIS_SUNDAE INT = 4,
			@QUANTIDADE_ADICIONAIS_ACAI_P INT = 3,
			@QUANTIDADE_ADICIONAIS_ACAI_M INT = 4,
			@QUANTIDADE_ADICIONAIS_ACAI_G INT = 5,

			@MAX_SABOR INT,
			@MAX_PRODUTO INT,
			@MAX_VENDA INT,
			@MAX_ADICIONAL INT,
			@MAX_VALOR INT,
			@MAX_LOCAL INT,
			@MAX_ESTABELECIMENTO INT

	SET @TOTAL_ITENS = (SELECT dbo.FN_ALEATORIO(RAND(), 10,1))

	-- SAVING MAX QUANTITIES FROM ITEMS TO BE INSERTED
	CREATE TABLE #TB_VOLUME_MAX (CATEGORIA VARCHAR(100), VOLUME INT)
	INSERT INTO #TB_VOLUME_MAX values('PICOLÉ',5)
	INSERT INTO #TB_VOLUME_MAX values ('BOLA DE SORVETE', 8)
	INSERT INTO #TB_VOLUME_MAX values ('SUNDAE', 4)
	INSERT INTO #TB_VOLUME_MAX values ('AÇAÍ P', 5)
	INSERT INTO #TB_VOLUME_MAX values ('AÇAÍ M', 5)
	INSERT INTO #TB_VOLUME_MAX values ('AÇAÍ G', 5)

	-- GENERATING RANDOM LOCAL
	CREATE TABLE #TB_LOCAL (ID INT IDENTITY(1,1), ID_LOCAL INT)
	INSERT INTO #TB_LOCAL SELECT L.ID FROM TB_LOCAL L
	SET @MAX_LOCAL = (SELECT count(*) FROM #TB_LOCAL)
	SET @ID_LOCAL = (	SELECT ID_LOCAL 
						FROM #TB_LOCAL 
						WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_LOCAL,1))
					)

	-- GENERATING RANDOM ESTABELECIMENTO
	CREATE TABLE #TB_ESTABELECIMENTO (ID INT IDENTITY(1,1), ID_ESTABELECIMENTO INT)
	INSERT INTO #TB_ESTABELECIMENTO SELECT E.ID FROM TB_ESTABELECIMENTO E WHERE E.ID_LOCAL = @ID_LOCAL
	SET @MAX_ESTABELECIMENTO = (SELECT count(*) FROM #TB_ESTABELECIMENTO)
	SET @ID_ESTABELECIMENTO = (SELECT ID_ESTABELECIMENTO 
						FROM #TB_ESTABELECIMENTO
						WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_ESTABELECIMENTO,1))
						)

	-- SAVING MAX VALUES FOR SABOR
	CREATE TABLE #TB_SABOR (ID INT IDENTITY(1,1), ID_SABOR INT)
	INSERT INTO #TB_SABOR SELECT S.ID FROM TB_SABOR S
	SET @MAX_SABOR = (SELECT count(*) FROM #TB_SABOR)

	-- SAVING MAX VALUES FOR ADICIONAL
	CREATE TABLE #TB_ADICIONAL (ID INT IDENTITY(1,1), ID_ADICIONAL INT)
	INSERT INTO #TB_ADICIONAL SELECT A.ID FROM TB_ADICIONAL A
	SET @MAX_ADICIONAL = (SELECT count(*) FROM #TB_ADICIONAL)

	-- GETTING ID OF PRODUCT
	SET @ID_PRODUTO = (SELECT P.ID FROM TB_PRODUTO P WHERE P.PRODUTO = @CATEGORIA)
	
	-- CREATING A EMPTY VENDA
	SET @ID_VENDA = NEXT VALUE FOR SQ_VENDA

	INSERT INTO TB_VENDA(ID, ID_ESTABELECIMENTO, DATA_VENDA, VALOR)
	VALUES(@ID_VENDA, @ID_ESTABELECIMENTO, @DATA, 0)

	-- SETTING VARIABLE TO SAVE THE TOTAL VALUE OF THE VENDA
	SET @VALOR_TOTAL = 0
	WHILE @CONTADOR_ITENS < @TOTAL_ITENS
	BEGIN
		-- GENERATING RANDOM SABOR
		IF @CATEGORIA IN ('PICOLÉ', 'BOLA DE SORVETE', 'SUNDAE')
		BEGIN
			SET @ID_SABOR = (	SELECT ID_SABOR 
							 	FROM #TB_SABOR
							 	WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_SABOR,1))
							 )
		END

		-- GENERATING RANDOM VALOR
		SET @VALOR = (SELECT P.VALOR FROM TB_PRODUTO P
	                         WHERE P.ID = @ID_PRODUTO)
							 
		SET @VALOR_TOTAL = @VALOR_TOTAL + @VALOR
		
		SET @ID_ITEM = NEXT VALUE FOR SQ_ITEM

		-- SAVING ITEM IN TB_ITEM
		INSERT INTO TB_ITEM(ID, ID_PRODUTO, ID_SABOR, ID_VENDA, VALOR)
		VALUES(@ID_ITEM, @ID_PRODUTO, @ID_SABOR, @ID_VENDA, @VALOR)
		SET @CONTADOR_ITENS = @CONTADOR_ITENS + 1

		-- GENERATING RANDOM ADICIONALS FOR SUNDAE AND SAVING
		IF @CATEGORIA = 'SUNDAE'
		BEGIN
			WHILE @CONTADOR_ADICIONAIS < @QUANTIDADE_ADICIONAIS_SUNDAE
			BEGIN
				SET @ID_ADICIONAL = (	SELECT ID_ADICIONAL 
							 			FROM #TB_ADICIONAL
							 			WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_ADICIONAL,1))
							 		)

				INSERT INTO TB_ITEM_ADICIONAL(ID_ADICIONAL, ID_ITEM)
				VALUES(@ID_ADICIONAL, @ID_ITEM)

				UPDATE TB_ITEM
				SET VALOR = VALOR + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				WHERE ID = @ID_ITEM

				SET @VALOR_TOTAL = @VALOR_TOTAL + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				SET @CONTADOR_ADICIONAIS = @CONTADOR_ADICIONAIS + 1
			END
			SET @CONTADOR_ADICIONAIS = 0
		END

		-- GENERATING RANDOM ADICIONALS FOR AÇAI P AND SAVING
		IF @CATEGORIA = 'AÇAÍ P'
		BEGIN
			WHILE @CONTADOR_ADICIONAIS < @QUANTIDADE_ADICIONAIS_ACAI_P
			BEGIN
				SET @ID_ADICIONAL = (	SELECT ID_ADICIONAL 
							 			FROM #TB_ADICIONAL
							 			WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_ADICIONAL,1))
							 		)

				INSERT INTO TB_ITEM_ADICIONAL(ID_ADICIONAL, ID_ITEM)
				VALUES(@ID_ADICIONAL, @ID_ITEM)

				UPDATE TB_ITEM
				SET VALOR = VALOR + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				WHERE ID = @ID_ITEM

				SET @VALOR_TOTAL = @VALOR_TOTAL + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				SET @CONTADOR_ADICIONAIS = @CONTADOR_ADICIONAIS + 1
			END
			SET @CONTADOR_ADICIONAIS = 0
		END

		-- GENERATING RANDOM ADICIONALS FOR AÇAI M AND SAVING
		IF @CATEGORIA = 'AÇAÍ M'
		BEGIN
			WHILE @CONTADOR_ADICIONAIS < @QUANTIDADE_ADICIONAIS_ACAI_M
			BEGIN
				SET @ID_ADICIONAL = (	SELECT ID_ADICIONAL 
							 			FROM #TB_ADICIONAL
							 			WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_ADICIONAL,1))
							 		)

				INSERT INTO TB_ITEM_ADICIONAL(ID_ADICIONAL, ID_ITEM)
				VALUES(@ID_ADICIONAL, @ID_ITEM)

				UPDATE TB_ITEM
				SET VALOR = VALOR + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				WHERE ID = @ID_ITEM

				SET @VALOR_TOTAL = @VALOR_TOTAL + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				SET @CONTADOR_ADICIONAIS = @CONTADOR_ADICIONAIS + 1
			END
			SET @CONTADOR_ADICIONAIS = 0
		END

		-- GENERATING RANDOM ADICIONALS FOR AÇAI G AND SAVING
		IF @CATEGORIA = 'AÇAÍ G'
		BEGIN
			WHILE @CONTADOR_ADICIONAIS < @QUANTIDADE_ADICIONAIS_ACAI_G
			BEGIN
				SET @ID_ADICIONAL = (	SELECT ID_ADICIONAL 
							 			FROM #TB_ADICIONAL
							 			WHERE ID = (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_ADICIONAL,1))
							 		)

				INSERT INTO TB_ITEM_ADICIONAL(ID_ADICIONAL, ID_ITEM)
				VALUES(@ID_ADICIONAL, @ID_ITEM)

				UPDATE TB_ITEM
				SET VALOR = VALOR + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				WHERE ID = @ID_ITEM

				SET @VALOR_TOTAL = @VALOR_TOTAL + (SELECT A.VALOR FROM TB_ADICIONAL A WHERE A.ID = @ID_ADICIONAL)
				SET @CONTADOR_ADICIONAIS = @CONTADOR_ADICIONAIS + 1
			END
			SET @CONTADOR_ADICIONAIS = 0
		END		
	END

	-- SETTING TOTAL VALUE OF VENDA
	UPDATE TB_VENDA
	SET VALOR = @VALOR_TOTAL
	WHERE ID = @ID_VENDA
END

-- PROCEDURE TO POPULATE TB_VENDA
GO
CREATE OR ALTER PROCEDURE SP_POVOAR_VENDAS(@DATA_INICIAL DATETIME, @DATA_FINAL DATETIME)
AS
BEGIN
	SET nocount on
    DECLARE @MAX_VENDAS_PICOLE INT = 10, 
	        @MIN_VENDAS_PICOLE INT = 1,
			@MAX_VENDAS_BOLA_SORVETE INT = 10,
			@MIN_VENDAS_BOLA_SORVETE INT = 1,
			@MAX_VENDAS_SUNDAE INT = 10, 
	        @MIN_VENDAS_SUNDAE INT = 1,
			@MAX_VENDAS_ACAI_P INT = 10, 
	        @MIN_VENDAS_ACAI_P INT = 1,
			@MAX_VENDAS_ACAI_M INT = 10, 
	        @MIN_VENDAS_ACAI_M INT = 1,
			@MAX_VENDAS_ACAI_G INT = 10, 
	        @MIN_VENDAS_ACAI_G INT = 1,

			@TOTAL_VENDAS_DIA_PICOLE INT,
			@TOTAL_VENDAS_DIA_BOLA_SORVETE INT,
			@TOTAL_VENDAS_DIA_SUNDAE INT,
			@TOTAL_VENDAS_DIA_ACAI_P INT,
			@TOTAL_VENDAS_DIA_ACAI_M INT,
			@TOTAL_VENDAS_DIA_ACAI_G INT,
			@CONTADOR_VENDAS INT = 0,
			@SEED FLOAT
			
    SELECT @SEED = RAND(10)

	-- GENERATING RANDOM NUMBER OF SALES FOR EACH CATEGORY
	WHILE (@DATA_INICIAL < @DATA_FINAL)
	BEGIN
		-- PICOLE
		SET @TOTAL_VENDAS_DIA_PICOLE = 
	               (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_VENDAS_PICOLE,@MIN_VENDAS_PICOLE))
		SET @CONTADOR_VENDAS = 0
		PRINT 'TOTAL VENDA PICOLÉ:' + STR(@TOTAL_VENDAS_DIA_PICOLE)
		WHILE (@CONTADOR_VENDAS < @TOTAL_VENDAS_DIA_PICOLE)
		BEGIN
			EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'PICOLÉ'
			SET @CONTADOR_VENDAS = @CONTADOR_VENDAS + 1
		END

		-- BOLA DE SORVETE
		SET @TOTAL_VENDAS_DIA_BOLA_SORVETE = 
	               (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_VENDAS_BOLA_SORVETE,@MIN_VENDAS_BOLA_SORVETE))
		SET @CONTADOR_VENDAS = 0
		PRINT 'TOTAL VENDA BOLA DE SORVETE:' + STR(@TOTAL_VENDAS_DIA_BOLA_SORVETE)
		WHILE (@CONTADOR_VENDAS < @TOTAL_VENDAS_DIA_BOLA_SORVETE)
		BEGIN
			EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'BOLA DE SORVETE'
			SET @CONTADOR_VENDAS = @CONTADOR_VENDAS + 1
		END

		-- SUNDAE
		SET @TOTAL_VENDAS_DIA_SUNDAE = 
	               (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_VENDAS_SUNDAE,@MIN_VENDAS_SUNDAE))
		SET @CONTADOR_VENDAS = 0
		PRINT 'TOTAL VENDA SUNDAE:' + STR(@TOTAL_VENDAS_DIA_SUNDAE)
		WHILE (@CONTADOR_VENDAS < @TOTAL_VENDAS_DIA_SUNDAE)
		BEGIN
			EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'SUNDAE'
			SET @CONTADOR_VENDAS = @CONTADOR_VENDAS + 1
		END

		-- AÇAÍ P
		SET @TOTAL_VENDAS_DIA_ACAI_P = 
	               (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_VENDAS_ACAI_P,@MIN_VENDAS_ACAI_P))
		SET @CONTADOR_VENDAS = 0
		PRINT 'TOTAL VENDA AÇAÍ P:' + STR(@TOTAL_VENDAS_DIA_ACAI_P)
		WHILE (@CONTADOR_VENDAS < @TOTAL_VENDAS_DIA_ACAI_P)
		BEGIN
			EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'AÇAÍ P'
			SET @CONTADOR_VENDAS = @CONTADOR_VENDAS + 1
		END

		-- AÇAÍ M
		SET @TOTAL_VENDAS_DIA_ACAI_M = 
	               (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_VENDAS_ACAI_M,@MIN_VENDAS_ACAI_M))
		SET @CONTADOR_VENDAS = 0
		PRINT 'TOTAL VENDA AÇAÍ M:' + STR(@TOTAL_VENDAS_DIA_ACAI_M)
		WHILE (@CONTADOR_VENDAS < @TOTAL_VENDAS_DIA_ACAI_M)
		BEGIN
			EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'AÇAÍ M'
			SET @CONTADOR_VENDAS = @CONTADOR_VENDAS + 1
		END

		-- AÇAÍ G
		SET @TOTAL_VENDAS_DIA_ACAI_G = 
	               (SELECT dbo.FN_ALEATORIO(RAND(), @MAX_VENDAS_ACAI_G, @MIN_VENDAS_ACAI_G))
		SET @CONTADOR_VENDAS = 0
		PRINT 'TOTAL VENDA AÇAÍ G:' + STR(@TOTAL_VENDAS_DIA_ACAI_G)
		WHILE (@CONTADOR_VENDAS < @TOTAL_VENDAS_DIA_ACAI_G)
		BEGIN
			EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'AÇAÍ G'
			SET @CONTADOR_VENDAS = @CONTADOR_VENDAS + 1
		END

		SET @DATA_INICIAL = @DATA_INICIAL + 1
	END
END

-- DQL

SELECT * FROM TB_ITEM_ADICIONAL

EXEC SP_POVOAR_VENDAS '2020-01-01', '2022-01-01'

DELETE TB_ITEM_ADICIONAL
DELETE TB_ITEM 
DELETE TB_VENDA

SELECT I.ID,P.PRODUTO, I.VALOR,  SUM(AD.VALOR) FROM TB_VENDA V 
JOIN TB_ITEM I 
ON V.ID = I.ID_VENDA 
JOIN TB_PRODUTO P
ON P.ID = I.ID_PRODUTO
JOIN TB_ITEM_ADICIONAL A 
ON A.ID_ITEM = I.ID 
JOIN TB_ADICIONAL AD 
ON AD.ID = A.ID_ADICIONAL
GROUP BY I.ID,P.PRODUTO, I.VALOR

SELECT * FROM TB_VENDA V
LEFT JOIN TB_ITEM I ON(I.ID_VENDA = V.ID)
JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)

SELECT MONTH(V.DATA_VENDA) AS 'MES', YEAR(V.DATA_VENDA) AS 'ANO', COUNT(V.ID) AS 'N VENDAS', SUM(V.VALOR) AS 'VALOR TOTAL' FROM TB_VENDA V
LEFT JOIN TB_ITEM I ON(I.ID_VENDA = V.ID)
JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)
GROUP BY MONTH(V.DATA_VENDA), YEAR(V.DATA_VENDA)
ORDER BY YEAR(V.DATA_VENDA), MONTH(V.DATA_VENDA)


SELECT * FROM TB_VENDA V
JOIN TB_ITEM I
ON V.ID = I.ID_VENDA
WHERE V.VALOR = 2300

SELECT DAY(V.DATA_VENDA) AS 'DIA',MONTH(V.DATA_VENDA) AS 'MES', YEAR(V.DATA_VENDA) AS 'ANO', COUNT(I.ID) AS 'ITENS VENDIDOS', SUM(V.VALOR) AS 'VALOR TOTAL' FROM TB_VENDA V
LEFT JOIN TB_ITEM I ON(I.ID_VENDA = V.ID)
JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)
GROUP BY DAY(V.DATA_VENDA), MONTH(V.DATA_VENDA), YEAR(V.DATA_VENDA)
ORDER BY YEAR(V.DATA_VENDA), MONTH(V.DATA_VENDA), DAY(V.DATA_VENDA)

SELECT * FROM TB_ITEM I JOIN TB_VENDA V ON V.ID = I.ID_VENDA WHERE MONTH(V.DATA_VENDA) = 1 AND DAY(V.DATA_VENDA) = 1 AND YEAR(V.DATA_VENDA) = 2020
ORDER BY ID_VENDA
SELECT * FROM TB_ADICIONAL A
JOIN TB_ITEM_ADICIONAL IA ON(A.ID = IA.ID_ADICIONAL)
SELECT V.VALOR, P.PRODUTO, A.ADICIONAL, S.SABOR, L.NOME, LO.CIDADE FROM TB_VENDA V
LEFT join TB_ITEM I ON (V.ID = I.ID_VENDA)
LEFT JOIN TB_ITEM_ADICIONAL IA ON (IA.ID_ITEM = I.ID)
LEFT JOIN TB_ADICIONAL A ON(IA.ID_ADICIONAL = A.ID)
LEFT JOIN TB_SABOR S ON (S.ID = I.ID_SABOR)
LEFT JOIN TB_ESTABELECIMENTO L ON(L.ID = V.ID_ESTABELECIMENTO)
LEFT JOIN TB_LOCAL LO ON(L.ID_LOCAL = LO.ID)
LEFT JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)