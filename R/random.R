#' Negate wrapper for NOT IN
#'
#' @importFrom purrr negate
#'
#' @export
#'
`%not_in%` <- purrr::negate(`%in%`)
