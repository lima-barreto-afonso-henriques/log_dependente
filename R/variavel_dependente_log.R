#' Previsão Corrigida para Modelos com Variável Dependente em Log (Wooldridge)
#'
#' Esta função implementa os procedimentos de correção de viés de Wooldridge
#' para modelos de regressão linear onde a variável dependente está em logaritmo.
#'
#' @param modelo_log Um objeto de classe \code{lm} estimado com log(y).
#' @param dados O data.frame original contendo as variáveis do modelo.
#' @param nome_y Uma string com o nome da variável dependente na escala original (nível).
#' @param novos_dados Opcional. Um data.frame com novos valores para prever.
#' @param conf_level Nível de confiança para o intervalo (padrão 0.95).
#' @param mostrar_diagnostico Lógico. Se TRUE (padrão), imprime os Alphas e R2 no console.
#' @param na.action Define como lidar com NAs nos novos dados. Padrão é \code{na.exclude}.
#'
#' @details
#' Quando prevemos y em um modelo log-nível, exp(log_y_hat) é um estimador
#' enviesado da média de y. Esta função fornece as correções:
#' \enumerate{
#'   \item \strong{Previsão Wooldridge (Alpha Til)}: Obtida via regressão de y sobre exp(log_y_hat) sem intercepto.
#'   \item \strong{Previsão Média (Alpha Chapéu)}: Baseada na média da exponencial dos resíduos.
#' }
#'
#' @return Um \code{data.frame} com as previsões corrigidas, intervalos de confiança e valores originais.
#'
#' @export
variavel_dependente_log <- function(
  modelo_log,
  dados,
  nome_y,
  novos_dados = NULL,
  conf_level = 0.95,
  mostrar_diagnostico = TRUE,
  na.action = na.exclude
) {
  # 1. Extração robusta da amostra original utilizada no modelo
  index_utilizado <- names(residuals(modelo_log))
  y_real_orig <- dados[index_utilizado, nome_y]
  log_y_hat_orig <- fitted(modelo_log)
  u_hat_orig <- residuals(modelo_log)
  m_hat_orig <- exp(log_y_hat_orig)

  # 2. Fatores de Correção (Alphas) - Calculados na amostra original
  alpha_0_chap <- mean(exp(u_hat_orig), na.rm = TRUE)

  pesos_orig <- weights(modelo_log)
  mod_aux <- lm(y_real_orig ~ 0 + m_hat_orig, weights = pesos_orig)
  alpha_0_til <- as.numeric(coef(mod_aux))

  # 3. Predição (Amostra vs Novos Dados)
  if (is.null(novos_dados)) {
    pred_obj <- predict(modelo_log, se.fit = TRUE)
    y_real_out <- y_real_orig
  } else {
    pred_obj <- predict(
      modelo_log,
      newdata = novos_dados,
      se.fit = TRUE,
      na.action = na.action
    )
    y_real_out <- rep(NA, nrow(novos_dados))
  }

  # 4. Cálculos das Previsões e Intervalos (Arredondados para 3 casas)
  m_hat_novo <- exp(pred_obj$fit)
  y_prev_wooldridge <- round(alpha_0_til * m_hat_novo, 3)
  y_prev_media <- round(alpha_0_chap * m_hat_novo, 3)

  t_critico <- qt((1 + conf_level) / 2, df = modelo_log$df.residual)
  ic_inf <- round(
    alpha_0_til * exp(pred_obj$fit - t_critico * pred_obj$se.fit),
    3
  )
  ic_sup <- round(
    alpha_0_til * exp(pred_obj$fit + t_critico * pred_obj$se.fit),
    3
  )

  # 5. Relatório de Diagnóstico (Arredondado para 3 casas)
  if (is.null(novos_dados) && mostrar_diagnostico) {
    r2_nivel <- cor(y_real_out, y_prev_wooldridge, use = "complete.obs")^2
    cat("\n--- Diagnóstico do Modelo (Wooldridge) ---\n")
    cat(
      "Fator de Correção por Regressão (Alpha Til):",
      round(alpha_0_til, 3),
      "\n"
    )
    cat(
      "Fator de Correção da Média (Alpha Chapéu):  ",
      round(alpha_0_chap, 3),
      "\n"
    )
    cat("R-Quadrado (Escala em Nível):              ", round(r2_nivel, 3), "\n")
    cat("------------------------------------------\n")
  }

  # 6. Organização do Data Frame de Saída (Tudo com 3 casas)
  # Ordem: Real -> Componentes do Log -> Previsão Ingênua -> Previsões Corrigidas e IC
  df_res <- data.frame(
    Real = round(y_real_out, 3),
    Log_Ajustado = round(pred_obj$fit, 3),
    Erro_Padrão_Log = round(pred_obj$se.fit, 3),
    Previsão_Ingênua = round(m_hat_novo, 3),
    Previsão_Média = y_prev_media,
    Previsão_Wooldridge = y_prev_wooldridge,
    IC_Inferior = ic_inf,
    IC_Superior = ic_sup
  )

  if (!is.null(novos_dados)) {
    df_res$Real <- NULL
  }

  return(df_res)
}
