GO
CREATE OR ALTER PROCEDURE SP_OLTP_PRODUTO(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_PRODUTO 
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_PRODUTO(DATA_CARGA, COD_PRODUTO, PRODUTO, VALOR)
	SELECT @DATA_CARGA, P.ID, P.PRODUTO, P.VALOR FROM TB_PRODUTO P
END

GO
CREATE OR ALTER PROCEDURE SP_OLTP_SABOR(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_SABOR 
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_SABOR(DATA_CARGA, ID, SABOR)
	SELECT @DATA_CARGA, S.ID, S.SABOR FROM TB_SABOR S
END

GO
CREATE OR ALTER PROCEDURE SP_OLTP_ESTABELECIMENTO(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_ESTABELECIMENTO
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_ESTABELECIMENTO(DATA_CARGA, ID, NOME, CNPJ)
	SELECT @DATA_CARGA, E.ID, E.NOME, E.CNPJ FROM TB_LOJA E
END

GO
CREATE OR ALTER PROCEDURE SP_OLTP_LOCAL(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_LOCAL
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_LOCAL(DATA_CARGA, ID, ESTADO, CIDADE, BAIRRO)
	SELECT @DATA_CARGA, L.ID, L.ESTADO, L.CIDADE, L.BAIRRO FROM TB_LOCAL L
END

GO
CREATE OR ALTER PROCEDURE SP_OLTP_ADICIONAL(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_ADICIONAL
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_ADICIONAL(DATA_CARGA, ID, ADICIONAL, VALOR)
	SELECT @DATA_CARGA, A.ID, A.ADICIONAL, A.VALOR FROM TB_ADICIONAL A
END

GO
CREATE OR ALTER PROCEDURE SP_OLTP_FATO_VENDA(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_FATO_VENDA
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_FATO_VENDA(DATA_CARGA, DATA_VENDA, COD_VENDA, COD_SABOR, COD_ESTABELECIMENTO, COD_LOCAL, COD_PRODUTO, QUANTIDADE, VALOR)
	SELECT @DATA_CARGA, V.DATA_VENDA, V.ID, S.ID, S.SABOR, L.ID, L.NOME, LC.ID, LC.CIDADE, P.ID, P.PRODUTO, 1, V.VALOR FROM TB_VENDA V
	LEFT JOIN TB_ITEM I ON(I.ID_VENDA = V.ID)
	LEFT JOIN TB_SABOR S ON(I.ID_SABOR = S.ID)
	LEFT JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)
	LEFT JOIN TB_LOJA L ON(V.ID_LOJA = L.ID_LOCAL)
	LEFT JOIN TB_LOCAL LC ON(L.ID_LOCAL = LC.ID)
END

/*GO
CREATE OR ALTER PROCEDURE SP_OLTP_BRIDGE_ADICIONAL(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE TB_AUX_BRIDGE_ADICIONAL
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO TB_AUX_BRIDGE_ADICIONAL(DATA_CARGA, ID, )
	SELECT @DATA_CARGA, IA.ID_ADICIONAL, IA.ID_ITEM FROM TB_ITEMADICIONAL IA
END*/

GO
CREATE OR ALTER PROCEDURE SP_DIM_PRODUTO(@DATA DATETIME)
AS
BEGIN
	DECLARE @data_carga DATETIME, @id_produto INT, @produto VARCHAR(50), @valor NUMERIC(10, 2)
	DECLARE @produto_temp VARCHAR(50), @valor_temp NUMERIC(10, 2)

	DECLARE C_PRODUTO CURSOR
	FOR SELECT P.DATA_CARGA, P.COD_PRODUTO, P.PRODUTO, P.VALOR FROM TB_AUX_PRODUTO P

	OPEN C_PRODUTO
	FETCH C_PRODUTO INTO @data_carga, @id_produto, @produto, @valor

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS (SELECT ID FROM DIM_PRODUTO WHERE @id_produto = ID)
		BEGIN
			INSERT INTO DIM_PRODUTO(PRODUTO, VALOR, DATA_INICIO, DATA_FIM, FL_CORRENTE)
			VALUES(@produto, @valor, @DATA_CARGA, NULL, 'SIM')	
		END
		ELSE
		BEGIN
			SELECT @produto_temp = P.PRODUTO, @valor_temp = P.VALOR
			FROM DIM_PRODUTO P
			WHERE P.ID = @id_produto AND P.FL_CORRENTE = 'SIM'

			IF @produto_temp <> @produto OR @valor_temp <> @valor
			BEGIN
				UPDATE DIM_PRODUTO
				SET FL_CORRENTE = 'NAO', DATA_FIM = @DATA
				WHERE ID = @id_produto AND FL_CORRENTE = 'SIM'

				INSERT INTO DIM_PRODUTO(PRODUTO, VALOR, DATA_INICIO, DATA_FIM, FL_CORRENTE)
				VALUES(@produto, @valor, @DATA_CARGA, NULL, 'SIM')
			END
		END
		FETCH C_PRODUTO INTO @data_carga, @id_produto, @produto, @valor
	END
	CLOSE C_PRODUTO
	DEALLOCATE C_PRODUTO
END

EXEC SP_OLTP_PRODUTO '2022-01-01'
EXEC SP_DIM_PRODUTO '2022-01-01'

UPDATE TB_AUX_PRODUTO
SET PRODUTO = 'PICOL'
WHERE COD_PRODUTO = 1

SELECT * FROM DIM_PRODUTO