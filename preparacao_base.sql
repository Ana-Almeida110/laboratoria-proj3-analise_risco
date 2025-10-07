-- ==============================================
-- Tratamento da tabela default 
-- ==============================================

-- * Transformação da tabela original em view com variáveis em português para melhor entendimento
View salva como “vw_inadimplencia”
CREATE OR REPLACE VIEW `projeto3-472311.Projeto3.vw_inadimplencia` AS 
SELECT 
user_id AS id_usuario, 
default_flag AS inadimplencia
FROM `projeto3-472311.Projeto3.tb_default`

-- 1. Verificar e tratar dados nulos
SELECT 
COUNT (*)
FROM `projeto3-472311.Projeto3.vw_inadimplencia`
WHERE id_usuario IS NULL
Não houveram dados nulos

--2. Identificar e tratar dados duplicados 
SELECT
id_usuario, 
inadimplencia,
COUNT(*) AS qtd_duplicados
FROM `projeto3-472311.Projeto3.vw_inadimplencia`
GROUP BY 
id_usuario,
inadimplencia
HAVING COUNT(*) > 1;
Não retornou dados duplicados

--3. Identificar e tratar dados fora do escopo de análise
SELECT *
FROM `projeto3-472311.Projeto3.vw_inadimplencia`
WHERE inadimplencia NOT IN (0, 1) OR inadimplencia IS NULL;
Não foram encontrados dados fora do escopo

--4. Identificar e tratar dados discrepantes em variáveis categóricas
Nesta tabela não haviam variáveis categóricas

--5. Identificar e tratar dados discrepantes em variáveis numéricas
Nesta tabela não haviam variáveis categóricas

--6. Criação de novas variáveis
Criação de uma view para classificar os clientes conforme sua pontualidade nos pagamentos:
SELECT
  tb1.id_usuario,
  CASE 
    WHEN SUM(CASE WHEN tb1.inadimplencia = 1 THEN 1 ELSE 0 END) > 0 
      THEN 'inadimplente'
    ELSE 'pontual'
  END AS classificacao_inadimplencia
FROM `projeto3-472311.Projeto3.vw_inadimplencia` AS tb1
GROUP BY tb1.id_usuario;
Consulta salva como “vw_class_cliente_inadimplencia”
--7. Unir tabelas
União das views (vw_inadimplencia e vw_dados_pessoais_cliente)
SELECT
tb1.id_usuario,
tb1.inadimplencia,
tb2.idade,
tb2.genero,
tb2.ultimo_salario_mensal,
tb2.numero_dependentes
FROM `projeto3-472311.Projeto3.vw_inadimplencia` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_dados_pessoais_cliente` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva como vw_inadimplencia-dados_pessoais

União das views (vw inadimplência e vw_detalhes_emprestimos)
SELECT
tb1.id_usuario,
tb1.inadimplencia,
tb2.atrasos_maior_90_dias,
tb2.uso_credito_sem_garantia,
tb2.qtd_atrasos_30_59_dias,
tb2.razao_endividamento,
tb2.qtd_atrasos_60_89_dias
FROM `projeto3-472311.Projeto3.vw_inadimplencia` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva como vw_inadimplencia-detalhes_emprestimos

União das 4 views com tratamento de campos nulos e faixas:
SELECT
tb1.id_usuario,
tb1.idade,
tb1.genero,
tb1.faixa_salario,
tb1.grupo_dependentes,

tb2.atrasos_maior_90_dias,
tb2.qtd_atrasos_30_59_dias,
tb2.qtd_atrasos_60_89_dias,
tb2.uso_credito_sem_garantia,
tb2.razao_endividamento,

tb3.id_emprestimo,
tb3.tipo_emprestimo,
•	
tb4.inadimplencia,
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente_tratado` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb2
ON tb1.id_usuario = tb2.id_usuario 
LEFT JOIN `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado` AS tb3
ON tb1.id_usuario = tb3.id_usuario
LEFT JOIN `projeto3-472311.Projeto3.vw_inadimplencia` AS tb4
ON tb1.id_usuario = tb4.id_usuario
Consulta salva como vw_4_tabelas_tratada

--8. Construir tabelas auxiliares
Criei uma consulta reunindo 4 tabelas (vw_dados_pessoais_cliente, vw_info_emprestimos, vw_detalhes_emprestimos e vw_inadimplencia

WITH
  resumo_emprestimo AS (
  SELECT
    id_usuario,
    COUNT(*) AS total_emprestimos,
    SUM(CASE
        WHEN tipo_emprestimo = 'imobiliario' THEN 1
        ELSE 0
    END
      ) AS emprestimo_imobiliario
  FROM
    `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado`
  GROUP BY
    id_usuario )
SELECT
  cl.id_usuario,
  cl.idade,
  cl.genero,
  cl.ultimo_salario_mensal,
  cl.numero_dependentes,
  COALESCE(re.total_emprestimos, 0) AS total_emprestimos,
  COALESCE(re.emprestimo_imobiliario, 0) AS emprestimo_imobiliario,
  inad.inadimplencia,
  det.atrasos_maior_90_dias,
  det.uso_credito_sem_garantia,
  det.qtd_atrasos_30_59_dias,
  det.razao_endividamento,
  det.qtd_atrasos_60_89_dias
FROM
  `projeto3-472311.Projeto3.vw_dados_pessoais_cliente` AS cl
LEFT JOIN
  resumo_emprestimo re
ON
  cl.id_usuario = re.id_usuario
LEFT JOIN
  `projeto3-472311.Projeto3.vw_inadimplencia` AS inad
ON
  cl.id_usuario = inad.id_usuario
LEFT JOIN
  `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS det
ON
  cl.id_usuario = det.id_usuario
Consulta salva como “vw_4_tabelas


-- ==============================================
-- Tratamento da tabela tb_loans_outstanding
-- ==============================================
-- * Transformação da tabela original em view com variáveis em português para melhor entendimento

View salva como “vw_info_emprestimos”
CREATE OR REPLACE VIEW
  `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS
SELECT
  user_id AS id_usuario,
  more_90_days_overdue AS atrasos_maior_90_dias,
  using_lines_not_secured_personal_assets AS uso_credito_sem_garantia,
  number_times_delayed_payment_loan_30_59_days AS qtd_atrasos_30_59_dias,
  debt_ratio AS razao_endividamento,
  number_times_delayed_payment_loan_60_89_days AS qtd_atrasos_60_89_dias
FROM
  `projeto3-472311.Projeto3.tb_loans_detail`

-- 1. Verificar e tratar dados nulos
SELECT 
COUNT (*)
FROM `projeto3-472311.Projeto3.vw_info_emprestimos`
WHERE id_usuario IS NULL
Não foram encontrados dados nulos

--2. Identificar e tratar dados duplicados 
vw_info_emprestimos (tb_loans_outstanding)
SELECT
id_usuario,
id_emprestimo,
tipo_emprestimo,
COUNT(*) AS qtd_duplicados
FROM `projeto3-472311.Projeto3.vw_info_emprestimos`
GROUP BY 
id_usuario,
id_emprestimo,
tipo_emprestimo
HAVING COUNT(*) > 1;
Este select não retornou registros duplicados

--3. Identificar e tratar dados fora do escopo de análise
SELECT *
FROM `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado`
WHERE id_usuario IS NULL
   OR id_emprestimo IS NULL
   OR tipo_emprestimo IS NULL;

SELECT id_emprestimo, COUNT(*) AS qtd
FROM `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado`
GROUP BY id_emprestimo
HAVING COUNT(*) > 1;   

SELECT id_usuario, COUNT(*) AS qtd_emprestimos
FROM `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado`
GROUP BY id_usuario
HAVING COUNT(*) > 1;

SELECT DISTINCT tipo_emprestimo
FROM `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado`
WHERE tipo_emprestimo NOT IN ('outros', 'imobiliario')
   OR tipo_emprestimo IS NULL;
Não foram encontrados dados fora do escopo

--4. Identificar e tratar dados discrepantes em variáveis categóricas
SELECT DISTINCT tipo_emprestimo
FROM `projeto3-472311.Projeto3.vw_info_emprestimos`Consulta salva como vw_spotify_limpo
A consulta retornou 7 registros com dados fora do padrão. Para corrigir executei o código:
SELECT
id_usuario,
id_emprestimo,
CASE 
    WHEN LOWER(tipo_emprestimo) = 'real estate' THEN 'imobiliário'
    WHEN LOWER(tipo_emprestimo) IN ('other', 'others') THEN 'outros'
    ELSE LOWER(tipo_emprestimo)
END AS tipo_emprestimo
FROM `projeto3-472311.Projeto3.vw_info_emprestimos`;
Consulta salva como vw_info_emprstimos_padronizado

--5. Identificar e tratar dados discrepantes em variáveis numéricas
Nesta tabela, não fazia sentido procurar dados discrepantes uma vez que as variáveis numéricas eram ids

--6. Criação de novas variáveis
Criação de uma view com informações do cliente e detalhes de suas operações de empréstimos

SELECT
dp.id_usuario,
SUM(CASE WHEN info.tipo_emprestimo = 'imobiliário' THEN 1 ELSE 0 END) AS qtd_imobiliario,
SUM(CASE WHEN info.tipo_emprestimo = 'outros' THEN 1 ELSE 0 END) AS qtd_outros
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente` AS dp
LEFT JOIN `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado` AS info
ON dp.id_usuario = info.id_usuario
GROUP BY dp.id_usuario
Foram criadas 3 variáveis: qtd_outros (quantidade de empréstimos do tipo outros), qtd_imobiliario – salvo como vw_dados_pessoais_qtd_emprestimos_tipo

--7. Unir tabelas
União das views (vw_info_emprestimos e vw_detalhes_emprestimos)
SELECT
tb1.id_usuario,
tb1.id_emprestimo,
tb1.tipo_emprestimo,
tb2.atrasos_maior_90_dias,
tb2.uso_credito_sem_garantia,
tb2.qtd_atrasos_30_59_dias,
tb2.qtd_atrasos_60_89_dias,
tb2.razao_endividamento
FROM `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva como vw_detalhes-info-emprestimos

--9. Construir tabelas auxiliares
Criação da tabela “vw_4_tabelas” descrita na seção anterior


-- ==============================================
--  Tratamento da tabela tb_loans_outstanding
-- ==============================================
-- * Transformação da tabela original em view com variáveis em português para melhor entendimento
CREATE OR REPLACE VIEW
  `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS
SELECT
  user_id AS id_usuario,
  more_90_days_overdue AS atrasos_maior_90_dias,
  using_lines_not_secured_personal_assets AS uso_credito_sem_garantia,
  number_times_delayed_payment_loan_30_59_days AS qtd_atrasos_30_59_dias,
  debt_ratio AS razao_endividamento,
  number_times_delayed_payment_loan_60_89_days AS qtd_atrasos_60_89_dias
FROM
  `projeto3-472311.Projeto3.tb_loans_detail`
Consulta salva como “vw_detalhes_emprestimos”

-- 1. Verificar e tratar dados nulos
SELECT COUNT (*) FROM`projeto3-472311.Projeto3.tb_loans_detail`
WHERE user_id IS NULL
A consulta não retornou dados nulos

--2. Identificar e tratar dados duplicados 
SELECT
id_usuario,
atrasos_maior_90_dias,
uso_credito_sem_garantia,
qtd_atrasos_30_59_dias,
razao_endividamento,
qtd_atrasos_60_89_dias,
COUNT(*) AS qtd_duplicados
FROM `projeto3-472311.Projeto3.vw_detalhes_emprestimos`
GROUP BY
id_usuario, 
atrasos_maior_90_dias,
uso_credito_sem_garantia,
qtd_atrasos_30_59_dias,
razao_endividamento,
qtd_atrasos_60_89_dias
HAVING COUNT(*) > 1;
Este select não retornou registros duplicados)

--3. Identificar e tratar dados fora do escopo de análise
SELECT
  CORR(atrasos_maior_90_dias, qtd_atrasos_30_59_dias) AS corr_90_30,
  CORR(atrasos_maior_90_dias, qtd_atrasos_60_89_dias) AS corr_90_60,
  CORR(qtd_atrasos_30_59_dias, qtd_atrasos_60_89_dias) AS corr_30_60,
  CORR(atrasos_maior_90_dias, uso_credito_sem_garantia) AS corr_90_sem_garantia,
  CORR(razao_endividamento, uso_credito_sem_garantia) AS corr_endividamento_sem_garantia
FROM
  `projeto3-472311.Projeto3.vw_detalhes_emprestimos`
Consulta salva como vw_corr_detalhes_emprestimos
Não foram encontrados dados fora do escopo

--4. Identificar e tratar dados discrepantes em variáveis categóricas
Não haviam variáveis categóricas na tabela

--5. Identificar e tratar dados discrepantes em variáveis numéricas
Uma das maneiras de encontrar outliers é pelo cálculo dos quartis. Executei o código seguinte:
WITH quartis AS (
  SELECT 
    APPROX_QUANTILES(atrasos_maior_90_dias, 4) AS quartis_maior_90,
    APPROX_QUANTILES(qtd_atrasos_30_59_dias, 4) AS quartis_30_59,
    APPROX_QUANTILES(qtd_atrasos_60_89_dias, 4) AS quartis_60_89,
    APPROX_QUANTILES(uso_credito_sem_garantia, 4) AS quartis_uso_credito,
    APPROX_QUANTILES(razao_endividamento, 4) AS quartis_endividamento,
  FROM `projeto3-472311.Projeto3.vw_detalhes_emprestimos`
)
SELECT
  id_usuario,
  atrasos_maior_90_dias,
  qtd_atrasos_30_59_dias,
  qtd_atrasos_60_89_dias,
  uso_credito_sem_garantia,
  razao_endividamento,

  -- Outlier para atrasos 30-59 dias
  CASE
    WHEN qtd_atrasos_30_59_dias < quartis_30_59[OFFSET(1)] - 1.5 * (quartis_30_59[OFFSET(3)] - quartis_30_59[OFFSET(1)]) 
    OR qtd_atrasos_30_59_dias > quartis_30_59[OFFSET(3)] + 1.5 * (quartis_30_59[OFFSET(3)] - quartis_30_59[OFFSET(1)]) 
      THEN 'Outlier' ELSE 'Normal'
  END AS status_30_59,

  -- Outlier para atrasos 60-89 dias
  CASE
    WHEN qtd_atrasos_60_89_dias < quartis_60_89[OFFSET(1)] - 1.5 * (quartis_60_89[OFFSET(3)] - quartis_60_89[OFFSET(1)]) 
    OR qtd_atrasos_60_89_dias > quartis_60_89[OFFSET(3)] + 1.5 * (quartis_60_89[OFFSET(3)] - quartis_60_89[OFFSET(1)]) 
      THEN 'Outlier' ELSE 'Normal'
  END AS status_60_89,

  -- Outlier para atrasos maior_90_dias
  CASE
    WHEN atrasos_maior_90_dias < quartis_maior_90[OFFSET(1)] - 1.5 * (quartis_maior_90[OFFSET(3)] - quartis_maior_90[OFFSET(1)]) 
    OR atrasos_maior_90_dias > quartis_maior_90[OFFSET(3)] + 1.5 * (quartis_maior_90[OFFSET(3)] - quartis_maior_90[OFFSET(1)]) 
      THEN 'Outlier' ELSE 'Normal'
  END AS status_maior_90,

  CASE
    WHEN uso_credito_sem_garantia < quartis_uso_credito[OFFSET(1)] - 1.5 * (quartis_uso_credito[OFFSET(3)] - quartis_uso_credito[OFFSET(1)])
      OR uso_credito_sem_garantia > quartis_uso_credito[OFFSET(3)] + 1.5 * (quartis_uso_credito[OFFSET(3)] - quartis_uso_credito[OFFSET(1)])
    THEN 'Outlier' ELSE 'Normal'
  END AS status_uso_credito,

  CASE
    WHEN razao_endividamento < quartis_endividamento[OFFSET(1)] - 1.5 * (quartis_endividamento[OFFSET(3)] - quartis_endividamento[OFFSET(1)])
      OR razao_endividamento > quartis_endividamento[OFFSET(3)] + 1.5 * (quartis_endividamento[OFFSET(3)] - quartis_endividamento[OFFSET(1)])
    THEN 'Outlier' ELSE 'Normal'
  END AS status_endividamento

FROM `projeto3-472311.Projeto3.vw_detalhes_emprestimos`, quartis

--6 . Criação de novas variáveis
Não foram criadas variáveis com esta tabela

--6. Unir tabelas
União das views (vw_info_emprestimos e vw_detalhes_emprestimos)
SELECT
tb1.id_usuario,
tb1.id_emprestimo,
tb1.tipo_emprestimo,
tb2.atrasos_maior_90_dias,
tb2.uso_credito_sem_garantia,
tb2.qtd_atrasos_30_59_dias,
tb2.qtd_atrasos_60_89_dias,
tb2.razao_endividamento
FROM `projeto3-472311.Projeto3.vw_info_emprestimos_padronizado` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva como vw_detalhes-info-emprestimos

União das views (vw inadimplência e vw_detalhes_emprestimos)

SELECT
tb1.id_usuario,
tb1.inadimplencia,
tb2.atrasos_maior_90_dias,
tb2.uso_credito_sem_garantia,
tb2.qtd_atrasos_30_59_dias,
tb2.razao_endividamento,
tb2.qtd_atrasos_60_89_dias
FROM `projeto3-472311.Projeto3.vw_inadimplencia` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva com vw_inadimplencia-detalhes_emprestimos

União das views (vw_detalhes_emprestimos e vw_dados_pessoais_cliente)

SELECT
tb1.id_usuario,
tb1.atrasos_maior_90_dias,
tb1.uso_credito_sem_garantia,
tb1.qtd_atrasos_30_59_dias,
tb1.razao_endividamento,
tb1.qtd_atrasos_60_89_dias,
tb2.idade,
tb2.genero,
tb2.ultimo_salario_mensal,
tb2.numero_dependentes
FROM `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_dados_pessoais_cliente` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva como vw_detalhes_emprest-dados_pessoais

--7. Construir tabelas auxiliares
Não foram construídas tabelas auxiliares


-- ==============================================
--  Tratamento da tabela tb_user_info
-- ==============================================
-- * Transformação da tabela original em view com variáveis em português para melhor entendimento
CREATE OR REPLACE VIEW
  `projeto3-472311.Projeto3.vw_dados_pessoais_cliente` AS
SELECT
  user_id AS id_usuario,
  age AS idade,
  sex AS genero,
  last_month_salary AS ultimo_salario_mensal,
  number_dependents AS numero_dependentes  
FROM
  `projeto3-472311.Projeto3.tb_user_info`
Consulta salva como “vw_dados_pessoais_cliente”

-- 1. Verificar e tratar dados nulos

SELECT 
COUNT (*)
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`
WHERE ultimo_salario_mensal IS NULL
A consulta retornou 7199 linhas com dados nulos

SELECT 
COUNT (*)
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`
WHERE numero_dependentes IS NULL
A consulta retornou 943 linhas com dados nulos

Para tratar, criei um campo com “Não informado” para os dados nulos com o seguinte select:
SELECT
id_usuario,
idade,
genero,
CASE 
    WHEN ultimo_salario_mensal IS NULL THEN 'Não informado'
    WHEN ultimo_salario_mensal BETWEEN 2001 AND 10000 THEN 'Até 10 mil'
    WHEN ultimo_salario_mensal BETWEEN 10001 AND 50000 THEN 'De 10 mil a 50 mil'
    WHEN ultimo_salario_mensal BETWEEN 50001 AND 200000 THEN 'De 50 mil a 200 mil'
    WHEN ultimo_salario_mensal BETWEEN 200001 AND 500000 THEN 'Entre 200 mil a 500 mil'
    ELSE 'Acima de 500 mil'
  END AS faixa_salario,
CASE 
    WHEN numero_dependentes IS NULL THEN 'Não informado'
    WHEN numero_dependentes =0 THEN 'Sem dependentes'
    WHEN numero_dependentes BETWEEN 1 AND 3 THEN '1 a 3 dependentes'
    WHEN numero_dependentes BETWEEN 4 AND 6 THEN '4 a 6 dependentes'
    WHEN numero_dependentes BETWEEN 7 AND 10 THEN '7 a 10 dependentes'
    ELSE 'Acima de 10 dependentes'
  END AS grupo_dependentes,
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`
Consulta salva como “vw_dados_pessoais_cliente_tratado”

--2. Identificar e tratar dados duplicados 
vw_dados_pessoais_cliente (tb_user_info)
SELECT
  id_usuario,
  idade,
  genero,
  ultimo_salario_mensal
  numero_dependentes,
  COUNT(*) AS quantidade
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`
GROUP BY
  id_usuario, 
  idade,
  genero,
  ultimo_salario_mensal,
  numero_dependentes
HAVING COUNT(*) > 1;
(Este select não retornou registros duplicados)

--3. Identificar e tratar dados fora do escopo de análise
vw_dados_pessoais_cliente (tb_user_info )

SELECT 
  CORR(idade, numero_dependentes) AS corr_idade_dependentes,
  CORR(idade, ultimo_salario_mensal) AS corr_idade_salario,
  CORR(numero_dependentes, ultimo_salario_mensal) AS corr_dependentes_salario,
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`

Correlações fracas para esta tabela
Variáveis como idade e genero entram na categoria de informações sensíveis e a inclusão em modelos preditivos devem ser evitadas. Para contornar, pode-se usar variáveis derivadas ou agregadas, por ex.: faixa_etaria (reduz identificação direta).
Consulta salva como vw_corr_detalhes_emprestimos

--4. Identificar e tratar dados discrepantes em variáveis categóricas
Não haviam variáveis categóricas na tabela com dados discrepantes

--5. Identificar e tratar dados discrepantes em variáveis numéricas
Uma das maneiras de encontrar outliers é pelo cálculo dos quartis. Executei o código seguinte:
SELECT
APPROX_QUANTILES(ultimo_salario_mensal, 4)[OFFSET(1)] AS Q1,
APPROX_QUANTILES(ultimo_salario_mensal, 4)[OFFSET(2)] AS Q2,
APPROX_QUANTILES(ultimo_salario_mensal, 4)[OFFSET(3)] AS Q3,
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`


SELECT
APPROX_QUANTILES(numero_dependentes, 4)[OFFSET(1)] AS Q1,
APPROX_QUANTILES(numero_dependentes, 4)[OFFSET(2)] AS Q2,
APPROX_QUANTILES(numero_dependentes, 4)[OFFSET(3)] AS Q3,
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`

Resultado:	 	

SELECT
APPROX_QUANTILES(idade, 4)[OFFSET(1)] AS Q1,
APPROX_QUANTILES(idade, 4)[OFFSET(2)] AS Q2,
APPROX_QUANTILES(idade, 4)[OFFSET(3)] AS Q3,
FROM `projeto3-472311.Projeto3.vw_dados_pessoais_cliente`

--6 . Criação de novas variáveis
Não foram criadas variáveis com esta tabela

--7. Unir tabelas
União das views (vw_inadimplencia e vw_dados_pessoais_cliente)
Consulta salva com vw_inadimplencia-dados_pessoais

União das views (vw_detalhes_emprestimos e vw_dados_pessoais_cliente)
SELECT
tb1.id_usuario,
tb1.atrasos_maior_90_dias,
tb1.uso_credito_sem_garantia,
tb1.qtd_atrasos_30_59_dias,
tb1.razao_endividamento,
tb1.qtd_atrasos_60_89_dias,
tb2.idade,
tb2.genero,
tb2.ultimo_salario_mensal,
tb2.numero_dependentes
FROM `projeto3-472311.Projeto3.vw_detalhes_emprestimos` AS tb1
LEFT JOIN `projeto3-472311.Projeto3.vw_dados_pessoais_cliente` AS tb2
ON tb1.id_usuario = tb2.id_usuario
Consulta salva como vw_detalhes_emprest-dados_pessoais

--7. Construir tabelas auxiliares
Construí a tabela vw_4_tabelas citada anteriormente
