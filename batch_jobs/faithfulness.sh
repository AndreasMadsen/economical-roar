#!/bin/bash
# jobs: 11
source "batch_jobs/_job_script.sh"
seeds="0 1 2 3 4"

declare -A size=( ["roberta-sb"]="small" ["roberta-sl"]="large"
                  ["roberta-m15"]="large" ["roberta-m20"]="large" ["roberta-m30"]="large" ["roberta-m40"]="large" ["roberta-m50"]="large" )


declare -A algo=( ["rand"]="rand"
                  ["grad-l1"]="grad" ["grad-l2"]="grad"
                  ["inp-grad-sign"]="inp-grad" ["inp-grad-abs"]="inp-grad"
                  ["int-grad-sign"]="int-grad" ["int-grad-abs"]="int-grad" )

#                   V100                                 V100                                 V100                                   V100
declare -A time=( # ["small test rand bAbI-1"]="0:02"  ["large test rand bAbI-1"]="0:03"  ["small train rand bAbI-1"]="1:??"  ["large train rand bAbI-1"]="1:??"
                    ["small test rand bAbI-1"]="0:10"  ["large test rand bAbI-1"]="0:10"  ["small train rand bAbI-1"]="1:10"  ["large train rand bAbI-1"]="1:10"
                  # ["small test rand bAbI-2"]="0:03"  ["large test rand bAbI-2"]="0:04"  ["small train rand bAbI-2"]="1:??"  ["large train rand bAbI-2"]="1:??"
                    ["small test rand bAbI-2"]="0:10"  ["large test rand bAbI-2"]="0:10"  ["small train rand bAbI-2"]="1:10"  ["large train rand bAbI-2"]="1:10"
                  # ["small test rand bAbI-3"]="0:04"  ["large test rand bAbI-3"]="0:04"  ["small train rand bAbI-3"]="1:??"  ["large train rand bAbI-3"]="1:??"
                    ["small test rand bAbI-3"]="0:10"  ["large test rand bAbI-3"]="0:10"  ["small train rand bAbI-3"]="1:10"  ["large train rand bAbI-3"]="1:10"
                  # ["small test rand BoolQ"]="0:09"   ["large test rand BoolQ"]="0:09"   ["small train rand BoolQ"]="0:08"   ["large train rand BoolQ"]="0:13"
                    ["small test rand BoolQ"]="0:15"   ["large test rand BoolQ"]="0:20"   ["small train rand BoolQ"]="0:15"   ["large train rand BoolQ"]="0:30"
                  # ["small test rand CB"]="0:05"      ["large test rand CB"]="0:06"      ["small train rand CB"]="0:06"      ["large train rand CB"]="0:05"
                    ["small test rand CB"]="0:15"      ["large test rand CB"]="0:15"      ["small train rand CB"]="0:15"      ["large train rand CB"]="0:15"
                  # ["small test rand CoLA"]="0:05"    ["large test rand CoLA"]="0:07"    ["small train rand CoLA"]="0:06"    ["large train rand CoLA"]="0:07"
                    ["small test rand CoLA"]="0:20"    ["large test rand CoLA"]="0:20"    ["small train rand CoLA"]="0:20"    ["large train rand CoLA"]="0:20"
                  # ["small test rand IMDB"]="0:18"    ["large test rand IMDB"]="0:41"    ["small train rand IMDB"]="0:15"    ["large train rand IMDB"]="0:34"
                    ["small test rand IMDB"]="0:30"    ["large test rand IMDB"]="1:00"    ["small train rand IMDB"]="0:30"    ["large train rand IMDB"]="1:00"
                  # ["small test rand MIMIC-a"]="0:03" ["large test rand MIMIC-a"]="0:04" ["small train rand MIMIC-a"]="1:??" ["large train rand MIMIC-a"]="1:??"
                    ["small test rand MIMIC-a"]="0:10" ["large test rand MIMIC-a"]="0:10" ["small train rand MIMIC-a"]="1:10" ["large train rand MIMIC-a"]="1:10"
                  # ["small test rand MIMIC-d"]="0:03" ["large test rand MIMIC-d"]="0:05" ["small train rand MIMIC-d"]="1:??" ["large train rand MIMIC-d"]="1:??"
                    ["small test rand MIMIC-d"]="0:10" ["large test rand MIMIC-d"]="0:10" ["small train rand MIMIC-d"]="1:10" ["large train rand MIMIC-d"]="1:10"
                  # ["small test rand MNLI"]="0:07"    ["large test rand MNLI"]="0:09"    ["small train rand MNLI"]="0:??"    ["large train rand MNLI"]="0:??"
                    ["small test rand MNLI"]="0:15"    ["large test rand MNLI"]="0:15"    ["small train rand MNLI"]="0:30"    ["large train rand MNLI"]="10:00"
                  # ["small test rand MRPC"]="0:06"    ["large test rand MRPC"]="0:07"    ["small train rand MRPC"]="0:15"    ["large train rand MRPC"]="0:07"
                    ["small test rand MRPC"]="0:15"    ["large test rand MRPC"]="0:20"    ["small train rand MRPC"]="0:30"    ["large train rand MRPC"]="0:20"
                  # ["small test rand QNLI"]="0:07"    ["large test rand QNLI"]="0:08"    ["small train rand QNLI"]="0:22"    ["large train rand QNLI"]="0:43"
                    ["small test rand QNLI"]="0:15"    ["large test rand QNLI"]="0:20"    ["small train rand QNLI"]="0:40"    ["large train rand QNLI"]="1:00"
                  # ["small test rand QQP"]="0:05"     ["large test rand QQP"]="0:14"     ["small train rand QQP"]="1:??"     ["large train rand QQP"]="0:??"
                    ["small test rand QQP"]="0:15"     ["large test rand QQP"]="0:30"     ["small train rand QQP"]="1:15"     ["large train rand QQP"]="0:30"
                  # ["small test rand RTE"]="0:07"     ["large test rand RTE"]="0:05"     ["small train rand RTE"]="0:08"     ["large train rand RTE"]="0:06"
                    ["small test rand RTE"]="0:20"     ["large test rand RTE"]="0:20"     ["small train rand RTE"]="0:20"     ["large train rand RTE"]="0:20"
                  # ["small test rand SST2"]="0:05"    ["large test rand SST2"]="0:06"    ["small train rand SST2"]="0:11"    ["large train rand SST2"]="0:17"
                    ["small test rand SST2"]="0:20"    ["large test rand SST2"]="0:20"    ["small train rand SST2"]="0:20"    ["large train rand SST2"]="0:30"
                  # ["small test rand WNLI"]="0:05"    ["large test rand WNLI"]="0:06"    ["small train rand WNLI"]="0:05"    ["large train rand WNLI"]="0:06"
                    ["small test rand WNLI"]="0:20"    ["large test rand WNLI"]="0:20"    ["small train rand WNLI"]="0:20"    ["large train rand WNLI"]="0:20"

                  # ["small test grad bAbI-1"]="0:04"  ["large test grad bAbI-1"]="0:07"" ["small train grad bAbI-1"]="1:??"  ["large train grad bAbI-1"]="1:??"
                    ["small test grad bAbI-1"]="0:15"  ["large test grad bAbI-1"]="0:15"  ["small train grad bAbI-1"]="1:10"  ["large train grad bAbI-1"]="1:10"
                  # ["small test grad bAbI-2"]="0:06"  ["large test grad bAbI-2"]="0:09"  ["small train grad bAbI-2"]="1:??"  ["large train grad bAbI-2"]="1:??"
                    ["small test grad bAbI-2"]="0:15"  ["large test grad bAbI-2"]="0:15"  ["small train grad bAbI-2"]="1:10"  ["large train grad bAbI-2"]="1:10"
                  # ["small test grad bAbI-3"]="0:05"  ["large test grad bAbI-3"]="0:08"  ["small train grad bAbI-3"]="1:??"  ["large train grad bAbI-3"]="1:??"
                    ["small test grad bAbI-3"]="0:15"  ["large test grad bAbI-3"]="0:15"  ["small train grad bAbI-3"]="1:10"  ["large train grad bAbI-3"]="1:10"
                  # ["small test grad BoolQ"]="0:12"   ["large test grad BoolQ"]="0:20"   ["small train grad BoolQ"]="0:17"   ["large train grad BoolQ"]="0:34"
                    ["small test grad BoolQ"]="0:20"   ["large test grad BoolQ"]="0:30"   ["small train grad BoolQ"]="0:30"   ["large train grad BoolQ"]="0:50"
                  # ["small test grad CB"]="0:08"      ["large test grad CB"]="0:08"      ["small train grad CB"]="0:10"      ["large train grad CB"]="0:10"
                    ["small test grad CB"]="0:15"      ["large test grad CB"]="0:15"      ["small train grad CB"]="0:20"      ["large train grad CB"]="0:30"
                  # ["small test grad CoLA"]="0:08"    ["large test grad CoLA"]="0:10"    ["small train grad CoLA"]="0:09"    ["large train grad CoLA"]="0:14"
                    ["small test grad CoLA"]="0:15"    ["large test grad CoLA"]="0:20"    ["small train grad CoLA"]="0:20"    ["large train grad CoLA"]="0:30"
                  # ["small test grad IMDB"]="0:55"    ["large test grad IMDB"]="0:??"    ["small train grad IMDB"]="0:42"    ["large train grad IMDB"]="0:??"
                    ["small test grad IMDB"]="1:10"    ["large test grad IMDB"]="2:00"    ["small train grad IMDB"]="1:00"    ["large train grad IMDB"]="2:00"
                  # ["small test grad MIMIC-a"]="0:05" ["large test grad MIMIC-a"]="0:10" ["small train grad MIMIC-a"]="1:??" ["large train grad MIMIC-a"]="1:??"
                    ["small test grad MIMIC-a"]="0:20" ["large test grad MIMIC-a"]="0:20" ["small train grad MIMIC-a"]="1:10" ["large train grad MIMIC-a"]="1:10"
                  # ["small test grad MIMIC-d"]="0:06" ["large test grad MIMIC-d"]="0:12" ["small train grad MIMIC-d"]="1:??" ["large train grad MIMIC-d"]="1:??"
                    ["small test grad MIMIC-d"]="0:20" ["large test grad MIMIC-d"]="0:25" ["small train grad MIMIC-d"]="1:10" ["large train grad MIMIC-d"]="1:10"
                  # ["small test grad MNLI"]="0:12"    ["large test grad MNLI"]="0:20"    ["small train grad MNLI"]="2:16"    ["large train grad MNLI"]="0:??"
                    ["small test grad MNLI"]="0:25"    ["large test grad MNLI"]="0:30"    ["small train grad MNLI"]="2:40"    ["large train grad MNLI"]="6:00"
                  # ["small test grad MRPC"]="0:09"    ["large test grad MRPC"]="0:10"    ["small train grad MRPC"]="0:09"    ["large train grad MRPC"]="0:11"
                    ["small test grad MRPC"]="0:20"    ["large test grad MRPC"]="0:20"    ["small train grad MRPC"]="0:30"    ["large train grad MRPC"]="0:20"
                  # ["small test grad QNLI"]="0:10"    ["large test grad QNLI"]="0:15"    ["small train grad QNLI"]="0:55"    ["large train grad QNLI"]="1:44"
                    ["small test grad QNLI"]="0:20"    ["large test grad QNLI"]="0:30"    ["small train grad QNLI"]="1:20"    ["large train grad QNLI"]="2:00"
                  # ["small test grad QQP"]="0:12"     ["large test grad QQP"]="0:40"     ["small train grad QQP"]="1:05"     ["large train grad QQP"]="3:00"
                    ["small test grad QQP"]="0:20"     ["large test grad QQP"]="1:00"     ["small train grad QQP"]="1:15"     ["large train grad QQP"]="4:00"
                  # ["small test grad RTE"]="0:06"     ["large test grad RTE"]="0:10"     ["small train grad RTE"]="0:08"     ["large train grad RTE"]="0:13"
                    ["small test grad RTE"]="0:20"     ["large test grad RTE"]="0:20"     ["small train grad RTE"]="0:20"     ["large train grad RTE"]="0:30"
                  # ["small test grad SST2"]="0:07"    ["large test grad SST2"]="0:09"    ["small train grad SST2"]="0:22"    ["large train grad SST2"]="0:42"
                    ["small test grad SST2"]="0:15"    ["large test grad SST2"]="0:20"    ["small train grad SST2"]="0:40"    ["large train grad SST2"]="1:00"
                  # ["small test grad WNLI"]="0:07"    ["large test grad WNLI"]="0:08"    ["small train grad WNLI"]="0:08"    ["large train grad WNLI"]="0:10"
                    ["small test grad WNLI"]="0:20"    ["large test grad WNLI"]="0:20"    ["small train grad WNLI"]="0:30"    ["large train grad WNLI"]="0:30"

                  # ["small test inp-grad bAbI-1"]="0:04"  ["large test inp-grad bAbI-1"]="0:07"" ["small train inp-grad bAbI-1"]="1:??"  ["large train inp-grad bAbI-1"]="1:??"
                    ["small test inp-grad bAbI-1"]="0:15"  ["large test inp-grad bAbI-1"]="0:20"  ["small train inp-grad bAbI-1"]="1:10"  ["large train inp-grad bAbI-1"]="1:10"
                  # ["small test inp-grad bAbI-2"]="0:05"  ["large test inp-grad bAbI-2"]="0:09"  ["small train inp-grad bAbI-2"]="1:??"  ["large train inp-grad bAbI-2"]="1:??"
                    ["small test inp-grad bAbI-2"]="0:15"  ["large test inp-grad bAbI-2"]="0:20"  ["small train inp-grad bAbI-2"]="1:10"  ["large train inp-grad bAbI-2"]="1:10"
                  # ["small test inp-grad bAbI-3"]="0:04"  ["large test inp-grad bAbI-3"]="0:08"  ["small train inp-grad bAbI-3"]="1:??"  ["large train inp-grad bAbI-3"]="1:??"
                    ["small test inp-grad bAbI-3"]="0:15"  ["large test inp-grad bAbI-3"]="0:20"  ["small train inp-grad bAbI-3"]="1:10"  ["large train inp-grad bAbI-3"]="1:10"
                  # ["small test inp-grad BoolQ"]="0:11"   ["large test inp-grad BoolQ"]="0:18"   ["small train inp-grad BoolQ"]="0:15"   ["large train inp-grad BoolQ"]="0:30"
                    ["small test inp-grad BoolQ"]="0:15"   ["large test inp-grad BoolQ"]="0:30"   ["small train inp-grad BoolQ"]="1:10"   ["large train inp-grad BoolQ"]="0:50"
                  # ["small test inp-grad CB"]="0:06"      ["large test inp-grad CB"]="0:07"      ["small train inp-grad CB"]="0:07"      ["large train inp-grad CB"]="0:09"
                    ["small test inp-grad CB"]="0:10"      ["large test inp-grad CB"]="0:15"      ["small train inp-grad CB"]="1:10"      ["large train inp-grad CB"]="0:20"
                  # ["small test inp-grad CoLA"]="0:07"    ["large test inp-grad CoLA"]="0:10"    ["small train inp-grad CoLA"]="0:08"    ["large train inp-grad CoLA"]="0:14"
                    ["small test inp-grad CoLA"]="0:15"    ["large test inp-grad CoLA"]="0:30"    ["small train inp-grad CoLA"]="0:20"    ["large train inp-grad CoLA"]="0:30"
                  # ["small test inp-grad IMDB"]="0:42"    ["large test inp-grad IMDB"]="1:42"    ["small train inp-grad IMDB"]="0:33"    ["large train inp-grad IMDB"]="1:28"
                    ["small test inp-grad IMDB"]="1:00"    ["large test inp-grad IMDB"]="2:00"    ["small train inp-grad IMDB"]="0:50"    ["large train inp-grad IMDB"]="1:50"
                  # ["small test inp-grad MIMIC-a"]="0:04" ["large test inp-grad MIMIC-a"]="0:09" ["small train inp-grad MIMIC-a"]="1:??" ["large train inp-grad MIMIC-a"]="1:??"
                    ["small test inp-grad MIMIC-a"]="0:20" ["large test inp-grad MIMIC-a"]="0:20" ["small train inp-grad MIMIC-a"]="1:10" ["large train inp-grad MIMIC-a"]="1:10"
                  # ["small test inp-grad MIMIC-d"]="0:05" ["large test inp-grad MIMIC-d"]="0:11" ["small train inp-grad MIMIC-d"]="1:??" ["large train inp-grad MIMIC-d"]="1:??"
                    ["small test inp-grad MIMIC-d"]="0:20" ["large test inp-grad MIMIC-d"]="0:30" ["small train inp-grad MIMIC-d"]="1:10" ["large train inp-grad MIMIC-d"]="1:10"
                  # ["small test inp-grad MNLI"]="0:11"    ["large test inp-grad MNLI"]="0:18"    ["small train inp-grad MNLI"]="1:55"    ["large train inp-grad MNLI"]="0:??"
                    ["small test inp-grad MNLI"]="0:15"    ["large test inp-grad MNLI"]="0:30"    ["small train inp-grad MNLI"]="2:30"    ["large train inp-grad MNLI"]="4:00"
                  # ["small test inp-grad MRPC"]="0:08"    ["large test inp-grad MRPC"]="0:09"    ["small train inp-grad MRPC"]="0:08"    ["large train inp-grad MRPC"]="0:11"
                    ["small test inp-grad MRPC"]="0:20"    ["large test inp-grad MRPC"]="0:20"    ["small train inp-grad MRPC"]="0:20"    ["large train inp-grad MRPC"]="0:20"
                  # ["small test inp-grad QNLI"]="0:10"    ["large test inp-grad QNLI"]="0:16"    ["small train inp-grad QNLI"]="0:45"    ["large train inp-grad QNLI"]="1:42"
                    ["small test inp-grad QNLI"]="0:20"    ["large test inp-grad QNLI"]="0:30"    ["small train inp-grad QNLI"]="1:00"    ["large train inp-grad QNLI"]="2:00"
                  # ["small test inp-grad QQP"]="0:10"     ["large test inp-grad QQP"]="0:39"     ["small train inp-grad QQP"]="1:05"     ["large train inp-grad QQP"]="4:04"
                    ["small test inp-grad QQP"]="0:20"     ["large test inp-grad QQP"]="1:00"     ["small train inp-grad QQP"]="1:15"     ["large train inp-grad QQP"]="5:00"
                  # ["small test inp-grad RTE"]="0:07"     ["large test inp-grad RTE"]="0:10"     ["small train inp-grad RTE"]="0:08"     ["large train inp-grad RTE"]="0:12"
                    ["small test inp-grad RTE"]="0:20"     ["large test inp-grad RTE"]="0:30"     ["small train inp-grad RTE"]="0:20"     ["large train inp-grad RTE"]="0:30"
                  # ["small test inp-grad SST2"]="0:08"    ["large test inp-grad SST2"]="0:09"    ["small train inp-grad SST2"]="0:18"    ["large train inp-grad SST2"]="0:36"
                    ["small test inp-grad SST2"]="0:20"    ["large test inp-grad SST2"]="0:20"    ["small train inp-grad SST2"]="0:30"    ["large train inp-grad SST2"]="1:20"
                  # ["small test inp-grad WNLI"]="0:06"    ["large test inp-grad WNLI"]="0:08"    ["small train inp-grad WNLI"]="0:08"    ["large train inp-grad WNLI"]="0:10"
                    ["small test inp-grad WNLI"]="0:20"    ["large test inp-grad WNLI"]="0:20"    ["small train inp-grad WNLI"]="0:20"    ["large train inp-grad WNLI"]="0:20"

                  # ["small test int-grad bAbI-1"]="0:07"  ["large test int-grad bAbI-1"]="0:14"" ["small train int-grad bAbI-1"]="1:??"  ["large train int-grad bAbI-1"]="1:??"
                    ["small test int-grad bAbI-1"]="0:20"  ["large test int-grad bAbI-1"]="0:25"  ["small train int-grad bAbI-1"]="1:10"  ["large train int-grad bAbI-1"]="1:10"
                  # ["small test int-grad bAbI-2"]="0:14"  ["large test int-grad bAbI-2"]="0:31"  ["small train int-grad bAbI-2"]="1:??"  ["large train int-grad bAbI-2"]="1:??"
                    ["small test int-grad bAbI-2"]="0:30"  ["large test int-grad bAbI-2"]="0:50"  ["small train int-grad bAbI-2"]="1:10"  ["large train int-grad bAbI-2"]="1:10"
                  # ["small test int-grad bAbI-3"]="0:21"  ["large test int-grad bAbI-3"]="0:57"  ["small train int-grad bAbI-3"]="1:??"  ["large train int-grad bAbI-3"]="1:??"
                    ["small test int-grad bAbI-3"]="0:40"  ["large test int-grad bAbI-3"]="1:10"  ["small train int-grad bAbI-3"]="1:10"  ["large train int-grad bAbI-3"]="1:10"
                  # ["small test int-grad BoolQ"]="0:48"   ["large test int-grad BoolQ"]="1:56"   ["small train int-grad BoolQ"]="1:37"   ["large train int-grad BoolQ"]="0:??"
                    ["small test int-grad BoolQ"]="1:00"   ["large test int-grad BoolQ"]="2:30"   ["small train int-grad BoolQ"]="2:00"   ["large train int-grad BoolQ"]="5:00"
                  # ["small test int-grad CB"]="0:06"      ["large test int-grad CB"]="0:09"      ["small train int-grad CB"]="0:09"      ["large train int-grad CB"]="0:12"
                    ["small test int-grad CB"]="0:15"      ["large test int-grad CB"]="0:20"      ["small train int-grad CB"]="0:20"      ["large train int-grad CB"]="0:30"
                  # ["small test int-grad CoLA"]="0:09"    ["large test int-grad CoLA"]="0:14"    ["small train int-grad CoLA"]="0:20"    ["large train int-grad CoLA"]="0:40"
                    ["small test int-grad CoLA"]="0:20"    ["large test int-grad CoLA"]="0:30"    ["small train int-grad CoLA"]="0:40"    ["large train int-grad CoLA"]="1:00"
                  # ["small test int-grad IMDB"]="7:39"    ["large test int-grad IMDB"]="22:07"   ["small train int-grad IMDB"]="7:31"    ["large train int-grad IMDB"]="0:??"
                    ["small test int-grad IMDB"]="8:30"    ["large test int-grad IMDB"]="23:30"   ["small train int-grad IMDB"]="8:30"    ["large train int-grad IMDB"]="23:30"
                  # ["small test int-grad MIMIC-a"]="0:26" ["large test int-grad MIMIC-a"]="1:11" ["small train int-grad MIMIC-a"]="1:??" ["large train int-grad MIMIC-a"]="1:??"
                    ["small test int-grad MIMIC-a"]="0:40" ["large test int-grad MIMIC-a"]="1:30" ["small train int-grad MIMIC-a"]="2:10" ["large train int-grad MIMIC-a"]="3:10"
                  # ["small test int-grad MIMIC-d"]="0:34" ["large test int-grad MIMIC-d"]="1:37" ["small train int-grad MIMIC-d"]="1:??" ["large train int-grad MIMIC-d"]="1:??"
                    ["small test int-grad MIMIC-d"]="1:00" ["large test int-grad MIMIC-d"]="2:00" ["small train int-grad MIMIC-d"]="2:10" ["large train int-grad MIMIC-d"]="4:10"
                  # ["small test int-grad MNLI"]="0:43"    ["large test int-grad MNLI"]="1:47"    ["small train int-grad MNLI"]="0:??"    ["large train int-grad MNLI"]="0:??"
                    ["small test int-grad MNLI"]="1:00"    ["large test int-grad MNLI"]="2:30"    ["small train int-grad MNLI"]="10:00"   ["large train int-grad MNLI"]="20:00"
                  # ["small test int-grad MRPC"]="0:08"    ["large test int-grad MRPC"]="0:14"    ["small train int-grad MRPC"]="0:17"    ["large train int-grad MRPC"]="0:34"
                    ["small test int-grad MRPC"]="0:20"    ["large test int-grad MRPC"]="0:30"    ["small train int-grad MRPC"]="0:35"    ["large train int-grad MRPC"]="0:50"
                  # ["small test int-grad QNLI"]="0:29"    ["large test int-grad QNLI"]="1:14"    ["small train int-grad QNLI"]="0:??"    ["large train int-grad QNLI"]="0:??"
                    ["small test int-grad QNLI"]="0:50"    ["large test int-grad QNLI"]="1:40"    ["small train int-grad QNLI"]="8:00"    ["large train int-grad QNLI"]="20:00"
                  # ["small test int-grad QQP"]="2:10"     ["large test int-grad QQP"]="5:40"     ["small train int-grad QQP"]="1:05"     ["large train int-grad QQP"]="0:??"
                    ["small test int-grad QQP"]="3:30"     ["large test int-grad QQP"]="6:40"     ["small train int-grad QQP"]="3:15"     ["large train int-grad QQP"]="40:00"
                  # ["small test int-grad RTE"]="0:09"     ["large test int-grad RTE"]="0:15"     ["small train int-grad RTE"]="0:20"     ["large train int-grad RTE"]="0:43"
                    ["small test int-grad RTE"]="0:20"     ["large test int-grad RTE"]="1:30"     ["small train int-grad RTE"]="0:40"     ["large train int-grad RTE"]="1:00"
                  # ["small test int-grad SST2"]="0:08"    ["large test int-grad SST2"]="0:14"    ["small train int-grad SST2"]="1:50"    ["large train int-grad SST2"]="4:40"
                    ["small test int-grad SST2"]="0:20"    ["large test int-grad SST2"]="0:30"    ["small train int-grad SST2"]="2:30"    ["large train int-grad SST2"]="5:30"
                  # ["small test int-grad WNLI"]="0:07"    ["large test int-grad WNLI"]="0:09"    ["small train int-grad WNLI"]="0:08"    ["large train int-grad WNLI"]="0:18"
                    ["small test int-grad WNLI"]="0:20"    ["large test int-grad WNLI"]="0:20"    ["small train int-grad WNLI"]="0:20"    ["large train int-grad WNLI"]="0:30" )


for model in 'roberta-sb' 'roberta-sl' # 'roberta-m15' 'roberta-m20' 'roberta-m30' 'roberta-m40' 'roberta-m50'
do
    for dataset in 'bAbI-1' 'bAbI-2' 'bAbI-3' 'BoolQ' 'CB' 'CoLA' 'IMDB' 'MIMIC-a' 'MIMIC-d' 'MNLI' 'MRPC' 'QNLI' 'QQP' 'RTE' 'SST2' 'WNLI'
    do
        for explainer in 'rand' 'grad-l1' 'grad-l2' 'inp-grad-abs' 'inp-grad-sign' 'int-grad-abs' 'int-grad-sign'
        do
            for masking_strategy in 'half-det' 'uni'
            do
                for split in 'test' 'train'
                do
                    submit_seeds "${time[${size[$model]} $split ${algo[$explainer]} $dataset]}" "$seeds" $(job_script gpu) \
                        experiments/faithfulness.py \
                        --model "${model}" \
                        --dataset "${dataset}" \
                        --max-masking-ratio 100 \
                        --masking-strategy "${masking_strategy}" \
                        --explainer "${explainer}" \
                        --split "${split}" \
                        --jit-compile \
                        --save-masked-datasets
                done
            done
        done
    done
done
