Construção de Estatísticas Descritivas por Intensidade Tecnologia
Pergunta: Os recursos do BNDES foram aportados em setores de maior intensidade tecnológica? Como se comportam as variáveis categóricas de Intensidade Tecnológica em um modelo de Regressão.
Resultados: Tabelas descritiva de valor BNDES e modelos de regressão 

Parte A:
	1 – Entender o funcionamento das classificações de intensidade tecnológica (OCDE, CEPAL, PAVITT). 
	2 - Realizar a inflação /deflação das variáveis de valor do BNDES.
	3 - Ler as bases da RAIS e construir uma variáveis categóricas de intensidade tecnológica: INTEC_OCDE, INTEC_CEPAL, INTEC_PAVIT, utilizando os tradutores CNAE2.0 x Classe de Tecnologia .
	4 - Construir Tabelas Descritivas com o valor: 
	5 - Construir a variável dependente do modelo de regressão: log(Valor BNDES / Massa Salarial)
	6 - Rodar modelos: 
	log(Valor BNDES / Massa Salarial) = beta0 + INTEC_OCDE
	log(Valor BNDES / Massa Salarial) = beta0 + INTEC_CEPAL
	log(Valor BNDES / Massa Salarial) = beta0 + INTEC_PAVIT

Parte B:

Construir um ”Estoque de Financiamentos” setorial.
Qual o “Estoque de Capital BNDES” por Setor de Intensidade Tecnológica? (OBS: Precisamos usar os dados novos e antigos do BNDES):
Aplicar Método do Inventário Perpétuo: K_t = (1-gamma) K_t-1 + I_t, ou seja, estoque de capital é o estoque do ano anterior depreciado mais os investimentos correntes. 
K_t:    Estoque acumulado de financiamentos (deflacionado) do BNDES (K_0=0)
K_t-1: Estoque acumulado de financiamentos (deflacionado) do BNDES no ano anterior;
I_t: Valor de financiamento (deflacionado) do BNDES no ano t
