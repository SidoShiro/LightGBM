context("lgb.prepare_rules2()")

test_that("lgb.prepare_rules2() rejects inputs that are not a data.table or data.frame", {
    bad_inputs <- list(
        matrix(1.0:10.0, 2L, 5L)
        , TRUE
        , c("a", "b")
        , NA
        , 10L
        , lgb.Dataset(
            data = matrix(1.0:10.0, 2L, 5L)
            , params = list()
        )
    )
    for (bad_input in bad_inputs) {
        expect_error({
            conversion_result <- lgb.prepare_rules2(bad_input)
        }, regexp = "lgb.prepare_rules2: you provided", fixed = TRUE)
    }
})

test_that("lgb.prepare_rules2() should work correctly for a dataset with only character columns", {
    testDF <- data.frame(
        col1 = c("a", "b", "c")
        , col2 =  c("green", "green", "red")
        , stringsAsFactors = FALSE
    )
    testDT <- data.table::as.data.table(testDF)
    for (input_data in list(testDF, testDT)) {
        conversion_result <- lgb.prepare_rules2(input_data)
        # dataset should have been converted to integer
        converted_dataset <- conversion_result[["data"]]
        expect_identical(class(input_data), class(converted_dataset))
        expect_identical(class(converted_dataset[["col1"]]), "integer")
        expect_identical(class(converted_dataset[["col2"]]), "integer")
        expect_identical(converted_dataset[["col1"]], c(1L, 2L, 3L))
        expect_identical(converted_dataset[["col2"]], c(1L, 1L, 2L))
        # rules should be returned and correct
        rules <- conversion_result$rules
        expect_is(rules, "list")
        expect_length(rules, ncol(input_data))
        expect_identical(rules[["col1"]], c("a" = 1L, "b" = 2L, "c" = 3L))
        expect_identical(rules[["col2"]], c("green" = 1L, "red" = 2L))
    }
})

test_that("lgb.prepare_rules2() should work correctly for a dataset with only factor columns", {
    testDF <- data.frame(
        col1 = as.factor(c("a", "b", "c"))
        , col2 =  as.factor(c("green", "green", "red"))
        , stringsAsFactors = FALSE
    )
    testDT <- data.table::as.data.table(testDF)
    for (input_data in list(testDF, testDT)) {
        conversion_result <- lgb.prepare_rules2(input_data)
        # dataset should have been converted to integer
        converted_dataset <- conversion_result[["data"]]
        expect_identical(class(input_data), class(converted_dataset))
        expect_identical(class(converted_dataset[["col1"]]), "integer")
        expect_identical(class(converted_dataset[["col2"]]), "integer")
        expect_identical(converted_dataset[["col1"]], c(1L, 2L, 3L))
        expect_identical(converted_dataset[["col2"]], c(1L, 1L, 2L))
        # rules should be returned and correct
        rules <- conversion_result$rules
        expect_is(rules, "list")
        expect_length(rules, ncol(input_data))
        expect_identical(rules[["col1"]], c("a" = 1L, "b" = 2L, "c" = 3L))
        expect_identical(rules[["col2"]], c("green" = 1L, "red" = 2L))
    }
})

test_that("lgb.prepare_rules2() should not change a dataset with only integer columns", {
    testDF <- data.frame(
        col1 = 11L:15L
        , col2 = 16L:20L
        , stringsAsFactors = FALSE
    )
    testDT <- data.table::as.data.table(testDF)
    for (input_data in list(testDF, testDT)) {
        conversion_result <- lgb.prepare_rules2(input_data)
        # dataset should have been converted to integer
        converted_dataset <- conversion_result[["data"]]
        expect_identical(converted_dataset, input_data)
        # rules should be returned and correct
        rules <- conversion_result$rules
        expect_identical(rules, list())
    }
})

test_that("lgb.prepare_rules2() should work correctly for a dataset with numeric, factor, and character columns", {
    testDF <- data.frame(
        character_col = c("a", "b", "c")
        , numeric_col = c(1.0, 9.0, 10.0)
        , factor_col = as.factor(c("n", "n", "y"))
        , stringsAsFactors = FALSE
    )
    testDT <- data.table::as.data.table(testDF)
    for (input_data in list(testDF, testDT)) {
        conversion_result <- lgb.prepare_rules2(input_data)
        # dataset should have been converted to numeric
        converted_dataset <- conversion_result[["data"]]
        expect_identical(class(input_data), class(converted_dataset))
        expect_identical(class(converted_dataset[["character_col"]]), "integer")
        expect_identical(class(converted_dataset[["factor_col"]]), "integer")
        expect_identical(converted_dataset[["character_col"]], c(1L, 2L, 3L))
        expect_identical(converted_dataset[["factor_col"]], c(1L, 1L, 2L))
        # rules should be returned and correct
        rules <- conversion_result$rules
        expect_is(rules, "list")
        expect_length(rules, 2L)
        expect_identical(rules[["character_col"]], c("a" = 1L, "b" = 2L, "c" = 3L))
        expect_identical(rules[["factor_col"]], c("n" = 1L, "y" = 2L))

        # today, lgb.prepare2() does  not convert numeric  columns
        expect_identical(class(converted_dataset[["numeric_col"]]), "numeric")
        expect_identical(converted_dataset[["numeric_col"]], c(1.0, 9.0, 10.0))
    }
})

test_that("lgb.prepare_rules2() should work correctly for a dataset with missing values", {
    testDF <- data.frame(
        character_col = c("a", NA_character_, "c")
        , na_col = rep(NA, 3L)
        , na_real_col = rep(NA_real_, 3L)
        , na_int_col = rep(NA_integer_,  3L)
        , na_character_col = rep(NA_character_, 3L)
        , numeric_col = c(1.0, 9.0, NA_real_)
        , factor_col = as.factor(c("n", "n", "y"))
        , integer_col = c(1L, 9L, NA_integer_)
        , stringsAsFactors = FALSE
    )
    testDT <- data.table::as.data.table(testDF)
    for (input_data in list(testDF, testDT)) {
        conversion_result <- lgb.prepare_rules2(input_data)
        # dataset should have been converted to integer
        converted_dataset <- conversion_result[["data"]]
        expect_identical(class(input_data), class(converted_dataset))

        expect_identical(class(converted_dataset[["character_col"]]), "integer")
        expect_identical(converted_dataset[["character_col"]], c(1L, NA_integer_, 2L))

        expect_identical(class(converted_dataset[["integer_col"]]), "integer")
        expect_identical(converted_dataset[["integer_col"]], c(1L, 9L, NA_integer_))

        expect_identical(class(converted_dataset[["factor_col"]]), "integer")
        expect_identical(converted_dataset[["factor_col"]], c(1L, 1L, 2L))

        # NAs of any type should be converted to numeric
        for (col in c("na_int_col", "na_character_col")) {
            expect_identical(class(converted_dataset[[col]]), "integer")
            expect_identical(converted_dataset[[col]], rep(NA_integer_, nrow(converted_dataset)))
        }

        # today, lgb.prepare2() does not convert logical columns
        expect_identical(class(converted_dataset[["na_col"]]), "logical")

        # today, lgb.prepare2() does not convert numeric columns to integer
        expect_identical(class(converted_dataset[["na_real_col"]]), "numeric")
        expect_identical(converted_dataset[["na_real_col"]], rep(NA_real_, nrow(converted_dataset)))
        expect_identical(class(converted_dataset[["numeric_col"]]), "numeric")
        expect_identical(converted_dataset[["numeric_col"]], c(1.0, 9.0, NA_real_))

        # rules should be returned and correct
        rules <- conversion_result$rules
        expect_is(rules, "list")
        expect_length(rules, 3L)
        expect_identical(rules[["character_col"]], stats::setNames(c(1L, NA_integer_, 2L), c("a", NA, "c")))
        expect_identical(rules[["na_character_col"]], stats::setNames(NA_integer_, NA))
        expect_identical(rules[["factor_col"]], c("n" = 1L, "y" = 2L))
    }
})

test_that("lgb.prepare_rules2() should work correctly if you provide your own well-formed rules", {
    testDF <- data.frame(
        character_col = c("a", NA_character_, "c", "a", "a", "c")
        , na_col = rep(NA, 6L)
        , na_real_col = rep(NA_real_, 6L)
        , na_int_col = rep(NA_integer_, 6L)
        , na_character_col = rep(NA_character_, 6L)
        , numeric_col = c(1.0, 9.0, NA_real_, 10.0, 11.0, 12.0)
        , factor_col = as.factor(c("n", "n", "y", "y", "n", "n"))
        , integer_col = c(1L, 9L, NA_integer_, 1L, 1L, 1L)
        , stringsAsFactors = FALSE
    )
    testDT <- data.table::as.data.table(testDF)
    # value used by lgb.prepare_rules2() when it encounters a categorical value that
    # is not in the provided rules
    UNKNOWN_FACTOR_VALUE <- 0L
    for (input_data in list(testDF, testDT)) {
        custom_rules <- list(
            "character_col" = c(
                "a" = 5L
                , "c" = -10L
            )
            , "factor_col" = c(
                "n" = 65L
                , "y" = 66L
            )
        )
        conversion_result <- lgb.prepare_rules2(
            data = input_data
            , rules = custom_rules
        )

        # dataset should have been converted to integer
        converted_dataset <- conversion_result[["data"]]
        expect_identical(class(input_data), class(converted_dataset))

        expect_identical(class(converted_dataset[["character_col"]]), "integer")
        expect_identical(converted_dataset[["character_col"]], c(5L, UNKNOWN_FACTOR_VALUE, -10L, 5L, 5L, -10L))

        expect_identical(class(converted_dataset[["factor_col"]]), "integer")
        expect_identical(converted_dataset[["factor_col"]], c(65L, 65L, 66L, 66L, 65L, 65L))

        # columns not specified in rules are not going to be converted
        for (col in c("na_col", "na_real_col", "na_int_col", "na_character_col", "numeric_col", "integer_col")) {
            expect_identical(converted_dataset[[col]], input_data[[col]])
        }

        # the rules you passed in should be returned unchanged
        rules <- conversion_result$rules
        expect_identical(rules, custom_rules)
    }
})

test_that("lgb.prepare_rules2() should modify data.tables in-place", {
    testDT <- data.table::data.table(
        character_col = c("a", NA_character_, "c")
        , na_col = rep(NA, 3L)
        , na_real_col = rep(NA_real_, 3L)
        , na_int_col = rep(NA_integer_,  3L)
        , na_character_col = rep(NA_character_, 3L)
        , numeric_col = c(1.0, 9.0, NA_real_)
        , factor_col = as.factor(c("n", "n", "y"))
        , integer_col = c(1L, 9L, NA_integer_)
    )
    conversion_result <- lgb.prepare_rules2(testDT)
    resultDT <- conversion_result[["data"]]
    expect_identical(resultDT, testDT)
})
