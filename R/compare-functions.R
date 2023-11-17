#' Compare the unique values in two character vectors
#'
#' @param vec_a A character vector
#' @param vec_b A character vector
#' @param fill_value A character value, default is NA_character_
#'
#' @return A dataframe
#' @export
#'
compare_unique_entries <- function(vec_a, vec_b, fill_value = NA_character_) {

  # Get sorted unique values
  a = sort(unique(vec_a))
  b = sort(unique(vec_b))

  # Get the longest value length
  l = max(length(a), length(b))

  # Organize into dataframe with extended vector lengths
  data.frame(
    "vec_a" = c(a, rep(fill_value, l - length(a))),
    "vec_b" = c(b, rep(fill_value, l - length(b)))
  )
}
