# log.dependente 📈

O pacote **log.dependente** fornece ferramentas para a correção de viés em previsões de modelos de regressão linear onde a variável dependente está em escala logarítmica ($\log y$). 

A implementação é baseada nos métodos discutidos por Jeffrey Wooldridge em seu livro *Introductory Econometrics* (Introdução à Econometria).

## 🧐 O Problema
Ao estimar um modelo $\log(y) = \beta_0 + \beta_1x + u$ e aplicar a função exponencial para retornar à escala original ($\exp(\widehat{\log y})$), obtemos um estimador da mediana, e não da média de $y$. Em dados com forte assimetria, como preços de imóveis ou salários, isso resulta em uma **subestimação sistemática** do valor real da média.



## 🚀 Solução
Este pacote implementa o **Procedimento de Wooldridge**, que utiliza fatores de correção ($\alpha$) para garantir que as previsões na escala original (nível) sejam consistentes e não enviesadas.

### Principais Funcionalidades:
- **Previsão Robusta**: Suporte para dados da amostra e predição para `novos_dados`.
- **Métodos de Correção**: 
  - **Alpha_0_chapéu**: Método da média da exponencial dos resíduos.
  - **Alpha_0_til**: Método de Wooldridge (regressão sem intercepto).
- **Intervalos de Confiança**: Cálculo de ICs (95% por padrão) já convertidos para a escala original.
- **Diagnóstico**: Relatório automático de $R^2$ na escala original e fatores de correção.
- **Flexibilidade**: Suporte para modelos com pesos (WLS) e tratamento de NAs.

### Glossário de Termos (Inglês vs. Português)
| Termo Original (Wooldridge) | Termo no Pacote | Descrição |
| :--- | :--- | :--- |
| $\hat{\alpha}_0$ (Method A) | `Alpha_0_chapéu` | Correção pela média dos resíduos |
| $\tilde{\alpha}_0$ (Method B) | `Alpha_0_til` | Correção por regressão de Wooldridge |
| Level scale | Escala em Nível | A escala original da variável (ex: Reais) |
| Naive Prediction | Previsão Ingênua | Previsão $\exp(\widehat{\log y})$ sem correção |

## 🛠 Instalação

Você pode instalar a versão de desenvolvimento diretamente do GitHub:

```r
# install.packages("devtools")
devtools::install_github("lima-barreto-afonso-henriques/log.dependente")


📖 Exemplo de Uso  
library(log.dependente)
library(wooldridge)

# 1. Estimar um modelo log-log ou log-nível
data(hprice2)
modelo <- lm(log(price) ~ log(nox) + rooms, data = hprice2)

# 2. Corrigir as previsões da amostra e ver diagnósticos
resultados <- variavel_dependente_log(modelo, hprice2, "price")
head(resultados)

# 3. Prever para um novo cenário (ex: casa com nox=5 e 6 quartos)
novas_casas <- data.frame(nox = 5, rooms = 6)
previsao_nova <- variavel_dependente_log(modelo, hprice2, "price", novos_dados = novas_casas)
print(previsao_nova)  


📚 Referência Bibliográfica
Wooldridge, Jeffrey M. Introductory Econometrics: A Modern Approach. Cengage Learning (Disponível em português como Introdução à Econometria: Uma Abordagem Moderna).
