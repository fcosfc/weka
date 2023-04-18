#!/bin/bash
#
# -------------------------------------------------------------------------------------------------------
# msu.sh: script que ejecuta versiones estándar de RandomForest, con ganancia de información como medida,
#         y la versión que utiliza la Multivariate Symmetrical Uncertainty (MSU) como medida, para luego
#         realizar una comparativa de las métricas resultado.
#
# author: Paco Saucedo.
# -------------------------------------------------------------------------------------------------------

# -----------------------
# Definición de variables
# -----------------------

WEKA_VERSION=3.8.7-SNAPSHOT.jar
WEKA_DIST=$PWD/dist/weka-stable-$WEKA_VERSION

DATASET_DIR=wekadocs/data
DATASET_FILE_EXTENSION=arff

STANDARD_CLASS=weka.classifiers.trees.RandomForest
MSU_CLASS=weka.classifiers.trees.RandomForestMSU
CLASS_ARGS="-P 100 -I 100 -num-slots 1 -K 0 -M 1.0 -V 0.001 -S 1"
ALGORITHM=RandomForest

J48_CLASS=weka.classifiers.trees.J48
J48_ARGS="-C 0.25 -M 2"

SCRIPT_DIR=$PWD/cli
WORK_DIR=/var/tmp
LIB_DIR=$PWD/lib/*

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

USE="msu.sh\n\tDATASET example weather.nominal\n\tDATASET_DIR ../$DATASET_DIR\n\n\tExample: cli/msu.sh weather.nominal ../$DATASET_DIR\n\n--\n\nmsu.sh\n\tDATASET example weather.nominal\n\tDATASET_DIR ../$DATASET_DIR\n\tALGORITHM Tree or Forest, default Tree\n\tWEKA_DIST default $WEKA_DIST\n\tLIB_DIR default $LIB_DIR\n\tSCRIPT_DIR default $SCRIPT_DIR\n\tWORK_DIR default $WORK_DIR\n\n\tExample: cli/msu.sh weather.nominal ../$DATASET_DIR Tree dist/weka-stable-3.8.7-SNAPSHOT.jar lib cli /var/tmp\n"

# -------------------------------
# Análisis de la línea de comando
# -------------------------------

if [ $# = 0 ];
then
    echo -e $USE
    exit
fi

if [ $# > 0 ];
then
    if [ $# = 2 ] || [ $# = 7 ];
    then
        if [ $# > 1 ]
        then
            DATASET_DIR=$2
        fi

        if [ $# = 7 ];
        then            
            if [ $3 = "Tree" ];
            then
                CLASS_ARGS="-K 0 -M 1.0 -V 0.001 -S 1"
                STANDARD_CLASS=weka.classifiers.trees.RandomTree
                MSU_CLASS=weka.classifiers.trees.RandomTreeMSU
            else
                if [ $3 != "Forest" ];
                then
                    printf "Algorithm %s not supported" $3
                    exit
                fi
            fi
            WEKA_DIST=$4
            LIB_DIR=$5/*
            SCRIPT_DIR=$6
            WORK_DIR=$7
        fi

        DATASET=$DATASET_DIR/$1.$DATASET_FILE_EXTENSION

        if [[ -f $DATASET ]];
        then
            printf "Dataset: %s\n" $DATASET
        else
            printf "Dataset %s not found\n" $DATASET
            exit
        fi     

        STANDARD_OUT=$WORK_DIR/$1.$TIMESTAMP.$ALGORITHM.out
        MSU_OUT=$WORK_DIR/$1.$TIMESTAMP.$ALGORITHM.msu.out
        J48_OUT=$WORK_DIR/$1.$TIMESTAMP.J48.out
        OUTPUT_CSV=$WORK_DIR/$1.$TIMESTAMP.csv   
    else
        echo "Wrong number of parameters"
        echo -e $USE
        exit
    fi
fi


# ----------------------
# Ejecución de programas
# ----------------------

printf "\nRunning %s %s\n" $STANDARD_CLASS "$CLASS_ARGS"
java -cp $WEKA_DIST:$LIB_DIR \
      $STANDARD_CLASS \
      $CLASS_ARGS -t $DATASET \
      > $STANDARD_OUT
printf "Output %s saved\n" $STANDARD_OUT

printf "\nRunning %s %s\n" $MSU_CLASS "$CLASS_ARGS"
java -cp $WEKA_DIST:$LIB_DIR \
      $MSU_CLASS \
      $CLASS_ARGS -t $DATASET \
      > $MSU_OUT
printf "Output %s saved\n" $MSU_OUT

printf "\nRunning %s %s\n" $J48_CLASS "$J48_ARGS"
java -cp $WEKA_DIST:$LIB_DIR \
      $J48_CLASS \
      $J48_ARGS -t $DATASET \
      > $J48_OUT
printf "Output %s saved\n" $J48_OUT

# --------------------------------
# Filtrado y cálculo de resultados
# --------------------------------

read RULES_ST INST_ST SECONDS_ST CORRCLASS_PC_ST INCORRCLASS_PC_ST KS_ST MAE_ST RMSE_ST RAE_ST RRSE_ST < \
 <(awk -f $SCRIPT_DIR/weka_results_analyzer.awk $STANDARD_OUT)

read RULES_MSU INST_MSU SECONDS_MSU CORRCLASS_PC_MSU INCORRCLASS_PC_MSU KS_MSU MAE_MSU RMSE_MSU RAE_MSU RRSE_MSU < \
 <(awk -f $SCRIPT_DIR/weka_results_analyzer.awk $MSU_OUT)

read RULES_J48 INST_J48 SECONDS_J48 CORRCLASS_PC_J48 INCORRCLASS_PC_J48 KS_ST MAE_J48 RMSE_J48 RAE_J48 RRSE_J48 < \
 <(awk -f $SCRIPT_DIR/weka_results_analyzer.awk $J48_OUT)

# Cálculo de comparativa. Bash no soporta por defecto operaciones con números decimales
ST_SECONDS_COMP=$(echo "($SECONDS_MSU-$SECONDS_ST)"| bc -l)
ST_CORRCLASS_PC_COMP=$(echo "($CORRCLASS_PC_MSU - $CORRCLASS_PC_ST)"| bc -l)
ST_INCORRCLASS_PC_COMP=$(echo "($INCORRCLASS_PC_MSU - $INCORRCLASS_PC_ST)"| bc -l)
ST_KS_COMP=$(echo "($KS_MSU - $KS_ST)"| bc -l)
ST_MAE_COMP=$(echo "($MAE_MSU - $MAE_ST)"| bc -l)
ST_RMSE_COMP=$(echo "($RMSE_MSU - $RMSE_ST)"| bc -l)
ST_RAE_COMP=$(echo "($RAE_MSU - $RAE_ST)"| bc -l)
ST_RRSE_COMP=$(echo "($RRSE_MSU - $RRSE_ST)"| bc -l)

J48_SECONDS_COMP=$(echo "($SECONDS_MSU - $SECONDS_J48)"| bc -l)
J48_CORRCLASS_PC_COMP=$(echo "($CORRCLASS_PC_MSU - $CORRCLASS_PC_J48)"| bc -l)
J48_INCORRCLASS_PC_COMP=$(echo "($INCORRCLASS_PC_MSU - $INCORRCLASS_PC_J48)"| bc -l)
J48_KS_COMP=$(echo "($KS_MSU - $KS_J48)"| bc -l)
J48_MAE_COMP=$(echo "($MAE_MSU - $MAE_J48)"| bc -l)
J48_RMSE_COMP=$(echo "($RMSE_MSU - $RMSE_J48)"| bc -l)
J48_RAE_COMP=$(echo "($RAE_MSU - $RAE_J48)"| bc -l)
J48_RRSE_COMP=$(echo "($RRSE_MSU - $RRSE_J48)"| bc -l)

# Conversión necesaria al formato decimal español, ya que el sistema operativo está en castellano y la salida de Weka no está internacionalizada
SECONDS_ST=$(echo $SECONDS_ST | sed "s/\./,/")
CORRCLASS_PC_ST=$(echo $CORRCLASS_PC_ST | sed "s/\./,/")
INCORRCLASS_PC_ST=$(echo $INCORRCLASS_PC_ST | sed "s/\./,/")
KS_ST=$(echo $KS_ST | sed "s/\./,/")
MAE_ST=$(echo $MAE_ST | sed "s/\./,/")
RMSE_ST=$(echo $RMSE_ST | sed "s/\./,/")
RAE_ST=$(echo $RAE_ST | sed "s/\./,/")
RRSE_ST=$(echo $RRSE_ST | sed "s/\./,/")

SECONDS_MSU=$(echo $SECONDS_MSU | sed "s/\./,/")
CORRCLASS_PC_MSU=$(echo $CORRCLASS_PC_MSU | sed "s/\./,/")
INCORRCLASS_PC_MSU=$(echo $INCORRCLASS_PC_MSU | sed "s/\./,/")
KS_MSU=$(echo $KS_MSU | sed "s/\./,/")
MAE_MSU=$(echo $MAE_MSU | sed "s/\./,/")
RMSE_MSU=$(echo $RMSE_MSU | sed "s/\./,/")
RAE_MSU=$(echo $RAE_MSU | sed "s/\./,/")
RRSE_MSU=$(echo $RRSE_MSU | sed "s/\./,/")

SECONDS_J48=$(echo $SECONDS_J48 | sed "s/\./,/")
CORRCLASS_PC_J48=$(echo $CORRCLASS_PC_J48 | sed "s/\./,/")
INCORRCLASS_PC_J48=$(echo $INCORRCLASS_PC_J48 | sed "s/\./,/")
KS_J48=$(echo $KS_J48 | sed "s/\./,/")
MAE_J48=$(echo $MAE_J48 | sed "s/\./,/")
RMSE_J48=$(echo $RMSE_J48 | sed "s/\./,/")
RAE_J48=$(echo $RAE_J48 | sed "s/\./,/")
RRSE_J48=$(echo $RRSE_J48 | sed "s/\./,/")

ST_SECONDS_COMP=$(echo $ST_SECONDS_COMP | sed "s/\./,/")
ST_CORRCLASS_PC_COMP=$(echo $ST_CORRCLASS_PC_COMP | sed "s/\./,/")
ST_INCORRCLASS_PC_COMP=$(echo $ST_INCORRCLASS_PC_COMP | sed "s/\./,/")
ST_KS_COMP=$(echo $ST_KS_COMP | sed "s/\./,/")
ST_MAE_COMP=$(echo $ST_MAE_COMP | sed "s/\./,/")
ST_RMSE_COMP=$(echo $ST_RMSE_COMP | sed "s/\./,/")
ST_RAE_COMP=$(echo $ST_RAE_COMP | sed "s/\./,/")
ST_RRSE_COMP=$(echo $ST_RRSE_COMP | sed "s/\./,/")

J48_SECONDS_COMP=$(echo $J48_SECONDS_COMP | sed "s/\./,/")
J48_CORRCLASS_PC_COMP=$(echo $J48_CORRCLASS_PC_COMP | sed "s/\./,/")
J48_INCORRCLASS_PC_COMP=$(echo $J48_INCORRCLASS_PC_COMP | sed "s/\./,/")
J48_KS_COMP=$(echo $J48_KS_COMP | sed "s/\./,/")
J48_MAE_COMP=$(echo $J48_MAE_COMP | sed "s/\./,/")
J48_RMSE_COMP=$(echo $J48_RMSE_COMP | sed "s/\./,/")
J48_RAE_COMP=$(echo $J48_RAE_COMP | sed "s/\./,/")
J48_RRSE_COMP=$(echo $J48_RRSE_COMP | sed "s/\./,/")

# ----------------------
# Creación CSV de salida
# ----------------------

printf "Metric;$ALGORITHM;$ALGORITHM MSU;Comparison MSU - Standard Version;J48;Comparison MSU - J48\n" > $OUTPUT_CSV
if [[ $3 = "Tree" ]];
then
    printf "Tree size;%s;%s;%s;%s;%s\n" $RULES_ST $RULES_MSU $(expr $RULES_MSU - $RULES_ST) $RULES_J48 $(expr $RULES_MSU - $RULES_J48) >> $OUTPUT_CSV
fi
printf "Total Number of Instances;%s;%s;%s;%s;%s\n" $INST_ST $INST_MSU $(expr $INST_MSU - $INST_ST) $INST_J48 $(expr $INST_MSU - $INST_J48) >> $OUTPUT_CSV
printf "Seconds taken to build model;%f;%f;%f;%f;%f\n" $SECONDS_ST $SECONDS_MSU $ST_SECONDS_COMP $SECONDS_J48 $J48_SECONDS_COMP >> $OUTPUT_CSV
printf "Correctly classified instances percentaje;%f;%f;%f;%f;%f\n" $CORRCLASS_PC_ST $CORRCLASS_PC_MSU $ST_CORRCLASS_PC_COMP $CORRCLASS_PC_J48 $J48_CORRCLASS_PC_COMP >> $OUTPUT_CSV
printf "Incorrectly classified instances percentaje;%f;%f;%f;%f;%f\n" $INCORRCLASS_PC_ST $INCORRCLASS_PC_MSU $ST_INCORRCLASS_PC_COMP $INCORRCLASS_PC_J48 $J48_INCORRCLASS_PC_COMP >> $OUTPUT_CSV
printf "Kappa statistic;%f;%f;%f;%f;%f\n" $KS_ST $KS_MSU $ST_KS_COMP $KS_J48 $J48_KS_COMP >> $OUTPUT_CSV
printf "Mean absolute error;%f;%f;%f;%f;%f\n" $MAE_ST $MAE_MSU $ST_MAE_COMP $MAE_J48 $J48_MAE_COMP >> $OUTPUT_CSV
printf "Root mean squared error;%f;%f;%f;%f;%f\n" $RMSE_ST $RMSE_MSU $ST_RMSE_COMP $RMSE_J48 $J48_RMSE_COMP >> $OUTPUT_CSV
printf "Relative absolute error;%f;%f;%f;%f;%f\n" $RAE_ST $RAE_MSU $ST_RAE_COMP $RAE_J48 $J48_RAE_COMP >> $OUTPUT_CSV
printf "Root relative squared error;%f;%f;%f;%f;%f\n" $RRSE_ST $RRSE_MSU $ST_RRSE_COMP $RRSE_J48 $J48_RRSE_COMP >> $OUTPUT_CSV
printf "\nComparison CSV %s saved\n" $OUTPUT_CSV