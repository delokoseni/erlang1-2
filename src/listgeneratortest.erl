%%%-------------------------------------------------------------------
%%% @author Артур
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. март 2026 12:53
%%%-------------------------------------------------------------------
-module(listgeneratortest).
-author("Артур").

-include_lib("eunit/include/eunit.hrl").

listGenerator_zero_test() -> ?assertEqual([0], listgenerator:listGenerator(0)).

listGenerator_one_test() -> ?assertEqual([1], listgenerator:listGenerator(1)).

listGenerator_single_digit_test() -> ?assertEqual([7], listgenerator:listGenerator(7)).

listGenerator_two_digits_test() -> ?assertEqual([1, 2], listgenerator:listGenerator(12)).

listGenerator_three_digits_test() -> ?assertEqual([1, 2, 3], listgenerator:listGenerator(123)).

listGenerator_with_inner_zero_test() -> ?assertEqual([1, 0, 2], listgenerator:listGenerator(102)).

listGenerator_with_multiple_zeros_test() -> ?assertEqual([1, 0, 0, 5], listgenerator:listGenerator(1005)).

listGenerator_trailing_zero_test() -> ?assertEqual([1, 2, 0], listgenerator:listGenerator(120)).

listGenerator_large_number_test() ->
    ?assertEqual(
        [9, 8, 7, 6, 5, 4, 3, 2, 1],
        listgenerator:listGenerator(987654321)
    ).

listGenerator_very_large_number_test() ->
    ?assertEqual(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5],
        listgenerator:listGenerator(123456789012345)
    ).

listGeneratorParallel_zero_test() -> ?assertEqual([0], listgenerator:listGeneratorParallel(0)).

listGeneratorParallel_one_test() -> ?assertEqual([1], listgenerator:listGeneratorParallel(1)).

listGeneratorParallel_single_digit_test() -> ?assertEqual([7], listgenerator:listGeneratorParallel(7)).

listGeneratorParallel_two_digits_test() -> ?assertEqual([1, 2], listgenerator:listGeneratorParallel(12)).

listGeneratorParallel_three_digits_test() -> ?assertEqual([1, 2, 3], listgenerator:listGeneratorParallel(123)).

listGeneratorParallel_with_inner_zero_test() -> ?assertEqual([1, 0, 2], listgenerator:listGeneratorParallel(102)).

listGeneratorParallel_with_multiple_zeros_test() ->
    ?assertEqual(
        [1, 0, 0, 5],
        listgenerator:listGeneratorParallel(1005)
    ).

listGeneratorParallel_trailing_zero_test() -> ?assertEqual([1, 2, 0], listgenerator:listGeneratorParallel(120)).

listGeneratorParallel_large_number_test() ->
    ?assertEqual(
        [9, 8, 7, 6, 5, 4, 3, 2, 1],
        listgenerator:listGeneratorParallel(987654321)
    ).

listGeneratorParallel_very_large_number_test() ->
    ?assertEqual(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5],
        listgenerator:listGeneratorParallel(123456789012345)
    ).