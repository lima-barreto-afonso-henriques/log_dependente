# Log Dependente
Implementação em R dos métodos de previsão para variáveis dependentes logarítmicas baseada em Wooldridge (Introductory Econometrics). Inclui funções para cálculo de alphas de correção e erros padrão.

# O Pacote Log Dependente 📈

O pacote **log.dependente** foi desenvolvido para facilitar a correção de viés em previsões de modelos de regressão linear onde a variável dependente está em escala logarítmica ($\log y$).

## 🧐 O Problema
Em econometria, ao estimar um modelo $\log(y) = \beta_0 + \beta_1x + u$, a simples aplicação da função exponencial na previsão, $\exp(\widehat{\log y})$, resulta em um estimador enviesado da média de $y$ (geralmente subestimando o valor real). 

## 🚀 Solução
Este pacote implementa o **Procedimento de Wooldridge**, que utiliza fatores de correção ($\alpha$) para garantir que as previsões na escala original (nível) sejam consistentes e não enviesadas.

### Funcionalidades:
- Cálculo da previsão "ingênua" ($\exp$).
- **Método A**: Correção via média simples dos resíduos ($\hat{\alpha}_0$).
- **Método B**: Correção via estimador de Wooldridge ($\tilde{\alpha}_0$) através de regressão sem intercepto.
- Fornece Erros Padrão da previsão e $R^2$ na escala original.

## 🛠 Instalação
Você pode instalar a versão de desenvolvimento diretamente do GitHub utilizando o pacote `devtools`:

### install.packages("devtools")
devtools::install_github("lima-barreto-afonso-henriques/log.dependente")

📖 Exemplo de Uso
library(log.dependente)
library(wooldridge)

#### 1. Estimar um modelo em log
modelo <- lm(log(price) ~ log(nox) + rooms, data = hprice2)

#### 2. Corrigir as previsões
resultados <- variavel_dependente_log(modelo, hprice2, "price")

#### 3. Visualizar o ajuste
head(resultados)


📚 Referência Bibliográfica
Wooldridge, Jeffrey M. Introductory Econometrics: A Modern Approach. Cengage Learning.

