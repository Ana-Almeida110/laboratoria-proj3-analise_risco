# Projeto 3  
## Ficha Técnica – Projeto 3: Risco Relativo

### Objetivo
Automatizar o processo de **análise de crédito** no banco *Super Caja* por meio de técnicas avançadas de análise de dados, visando aumentar a eficiência, precisão e agilidade na avaliação de pedidos de empréstimo.  

A análise busca:
- Identificar o perfil de clientes com risco de inadimplência;  
- Desenvolver uma pontuação de crédito (score);  
- Classificar clientes em categorias de risco.

### Equipe
- Projeto desenvolvido por **Ana Paula de Almeida Coiado**

### Ferramentas e Tecnologias
- Google BigQuery → armazenamento e análise (SQL)  
- Looker Studio → visualizações e dashboards  
- Planilhas Google e Python → apoio para histogramas
  
---

## Processamento e Análises

#### Importação dos Dados
- Criação da base no BigQuery com arquivos `.csv` disponibilizados:
  - `default.csv`
  - `loans_detail.csv`
  - `loans_outstanding.csv`
  - `user_info.csv`

#### Tratamento de Dados
> *Foram criadas views com nomes das variáveis em português para facilitar o entendimento.*

- Tratamento de **dados nulos** (`IS NULL`, `IS NOT NULL`, `COALESCE`)  
- Identificação e tratamento de **valores duplicados** (`COUNT`, `GROUP BY`, `HAVING`)  
- Detecção de **valores fora do escopo** com `CORR`  
- Padronização de **dados categóricos** (`UPPER`, `LOWER`, `CASE WHEN`, `IF`)  
- Identificação de **outliers** com quartis usando `APPROX_QUANTILES`  
- Armazenamento das queries como **views** para uso posterior  

#### Criação de Novas Variáveis
- Utilização de `DISTINCT` e `SUM` para novas métricas  
- Criação de **views** para facilitar manipulação  
- União de tabelas com `LEFT JOIN` e `JOIN`  
- Construção de **tabelas temporárias** (`WITH`) para cálculos  

---

#### Análise Exploratória (EDA)
- Conexão do Looker Studio com as tabelas do BigQuery  
- Agrupamento e visualização de variáveis categóricas (barras, colunas, tabelas, dispersão)  
- Aplicação de medidas de tendência central: **média, mediana e moda**  
- Visualização da distribuição (histogramas e boxplots)  
- Aplicação de medidas de dispersão: **desvio padrão**

---

#### Técnicas de Análise
- Criação de **categorias com base em quartis** no BigQuery e Looker Studio  
- Cálculo de **correlação de Pearson** (`CORR`) e visualização no gráfico de dispersão  
- Cálculo do **risco relativo** de grupos em relação à variável *inadimplência*  
- Segmentação de clientes por **score de risco**  
- Criação de **variáveis dummy** com `IF` para definir ponto de corte  

---

#### Dashboard
- Tabela resumo e **scorecards** com principais indicadores  
- Gráficos simples (barras) e avançados (bivariados/multivariados)  
- Aplicação de **filtros interativos** para navegação  

---

### Resultados e Conclusões
- Clientes com **maior uso de crédito** tendem a apresentar **salários mais baixos**, indicando dependência financeira.  
- Clientes com **salários mais altos** apresentam **menor uso de crédito**.  
- O **gráfico de dispersão** mostra que, embora a maioria esteja nas faixas mais baixas de crédito e endividamento, há um grupo menor com **altos valores em ambas**, sinalizando **maior risco**.  
- A **linha de tendência positiva** confirma correlação entre uso de crédito e razão de endividamento.  
- A maioria dos clientes está em **risco baixo ou moderado**, mas há uma parcela relevante em **alto risco**, demandando acompanhamento e reavaliação.  
- **Salários médios** caem conforme aumenta o endividamento, reforçando o risco de inadimplência.  
- Constatou-se correlação entre **uso elevado de crédito**, **alta razão de endividamento** e **inadimplência**, destacando a importância de políticas de crédito diferenciadas.  

---

### Limitações / Próximos Passos

#### Limitações
- Ausência de dados mais granulares sobre **valores e prazos** dos empréstimos torna a análise parcialmente subjetiva.

#### Próximos Passos
- Incluir na base:
  - Valor e prazo dos contratos;  
  - Tipo de empréstimo (por valor e prazo).  

---

### Links de Interesse

- [Projeto no Looker Studio](https://lookerstudio.google.com/s/qs6T0kJmgR8)  
- [Ficha Técnica (Notion)](https://www.notion.so/2858dc77aa2d80d3aeb8d9cb6006b733?pvs=25)
- [Comandos SQL utilizados na preparação da base](https://github.com/Ana-Almeida110/laboratoria-proj2_hipoteses/blob/main/preparacao_base.sql)  
- [Repositório no GitHub](https://github.com/Ana-Almeida110/laboratoria-proj2_hipoteses.git)  
- [Apresentação (Loom)](https://www.loom.com/share/18aae5c769d744f195b42016546dbd54?sid=23ef9201-f091-4837-ada1-4db1ad353ff9)
- [Apresentação (Slides)](https://docs.google.com/presentation/d/1wcZL3PGoHV6FuXbGO_GM0w0fKjaqCaE7/edit?usp=sharing&ouid=112893683117403532765&rtpof=true&sd=true)
