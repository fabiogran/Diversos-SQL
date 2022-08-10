--=======================
-- CTE RECURSIVA
--=======================

BEGIN
	WITH CTE AS (
				  SELECT
				  	ID = 1
				  UNION ALL
				  SELECT 
				  	ID + 1
				  FROM
				  	CTE
				  WHERE
				  	ID < 5
	) SELECT 
		NOME = CONCAT('NOME_', ID, ' = MAX(CASE WHEN ROWNO = ', ID, ' THEN NOME END)')
		,EMAIL = CONCAT('EMAIL_', ID, ' = MAX(CASE WHEN ROWNO = ', ID, ' THEN EMAIL END)')
		,TELEFONE = CONCAT('TELEFONE_', ID, ' = MAX(CASE WHEN ROWNO = ', ID, ' THEN TELEFONE END)')
	  FROM
	  	CTE
END

--====================================================================
-- LISTA OBJETOS NÃO UTILIZADOS NO BANCO PARA MANUTENÇÃO/LIMPEZA
--====================================================================
USE DATABASE --ESCOLHER DATABASE A QUAL SE DESEJA LISTAR OS OBJETOS

IF OBJECT_ID('DATABASE.SCHEMA.NOME_TABELA') IS NOT NULL
	DROP TABLE DATABASE.SCHEMA.NOME_TABELA

BEGIN
	WITH TMP_NAO_UTILIZADO AS (

								SELECT
									NOME_TB = DBTABLE.NOME_TABELA
									,TOTAL_LINHAS = PS.ROW_COUNT
									,DATA_CRIACAO = DBTABLE.CREATE_DATE
									,DATA_ULTIMA_MODIFICACAO = DBTABLE.MODIFY_DATE
									,TIPO_OBJETO = CASE
													  WHEN [TYPE] IN ('FN', 'IF', 'FS', 'AF', 'TF') THEN 'FUNCTION'
													  WHEN [TYPE] IN ('P', 'PC', 'X') THEN 'PROCEDURE'
													  WHEN [TYPE] IN ('U', 'S', 'IT') THEN 'TABLE'
													  WHEN [TYPE] = 'V' THEN 'VIEW'
													  WHEN [TYPE] = 'TR' THEN 'TRIGGER'
													  ELSE 'INDETERMINADO'
												   END
								FROM
									SYS.ALL_OBJECTS DBTABLE
										INNER JOIN SYS.DM_DB_PARTITION_STATS PS
											ON DBTABLE.NAME = OBJECT_NAME(PS.OBJECT_ID)
								WHERE
									DTABLE.[TYPE] IN ('FN', 'IF', 'FS', 'AF', 'TF', 'P', 'PC', 'X', 'U', 'S', 'IT', 'V', 'TR')
									AND NOT EXISTS (SELECT OBJECT_ID FROM SYS.DM_DB_INDEX_USAGE_STATS WHERE OBJECT_ID = DBTABLE.OBJECT_ID)
	)
	SELECT
		NOME_TB
		,TOTAL_LINHAS
		,DATA_CRIACAO
		,DATA_ULTIMA_MODIFICACAO
		,TIPO_OBJETO
	-- INTO
	--	DATABASE.SCHEMA.NOME_TABELA
	FROM
		TMP_NAO_UTILIZADO
	ORDER BY
		DATA_CRIACAO
		,TOTAL_LINHAS DESC
END



--====================================================================
--RETORNA TABELAS PARA REBUILD / COMPRESSAO
--====================================================================
USE DATABASE --ESCOLHER DATABASE PARA LISTAR TABELAS PARA COMPRESSAO

SELECT DISTINCT
	DB_NAME()
	,SC.NAME
	,ST.NAME
	,SP.DATA_COMPRESSION_DESC
	,TABELAS_COMPRESSAO = CONCAT('ALTER TABLE ', ST.NAME, ' REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)')
FROM
	SYS.PARTITIONS SP
		INNER JOIN SYS.ALLOCATION_UNITS SAU
			ON SP.PARTITION_ID = SAU.CONTAINER_ID
		INNER JOIN SYS.TABLES ST
			ON SP.OBJECT_ID = ST.OBJECT_ID
		INNER JOIN SYS.SCHEMAS SC
			ON SP.SCHEMA_ID = SC.SCHEMA_ID
WHERE
	SP.DATA_COMPRESSION_DESC = 'NONE'


--=======================================
-- TRATAMENTO MANUAL DE ERROS DE ENCODE
--=======================================
UPDATE TABELA
	SET CAMPO = REPLACE(CAMPO, 'Ã£', 'ã')
	SET CAMPO = REPLACE(CAMPO, 'Ã©', 'é')
	SET CAMPO = REPLACE(CAMPO, 'Ãº', 'ú')
	SET CAMPO = REPLACE(CAMPO, 'Ãº', 'ô')
	SET CAMPO = REPLACE(CAMPO, 'Ã§', 'ç')
	SET CAMPO = REPLACE(CAMPO, 'Ã¡', 'á')
	SET CAMPO = REPLACE(CAMPO, 'Ãª', 'ê')
	SET CAMPO = REPLACE(CAMPO, 'Ã³', 'ó')
	SET CAMPO = REPLACE(CAMPO, 'Ã¢', 'â')
	SET CAMPO = REPLACE(CAMPO, 'Ãµ', 'õ')
	SET CAMPO = REPLACE(CAMPO, 'Ãƒ', 'ã')
	SET CAMPO = REPLACE(CAMPO, 'Ã‡', 'Ç')
