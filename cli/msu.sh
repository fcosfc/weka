#!/bin/bash
#
# -------------------------------------------------------------------------------------------------------
# msu.sh: script que ejecuta versiones estándar de RandomForest, con ganancia de información como medida,
#         y la versión que utiliza la Multivariate Symmetrical Uncertainty (MSU) como medida, para luego
#         realizar una comparativa de las métricas resultado.
#
# author: Paco Saucedo.
# -------------------------------------------------------------------------------------------------------

WEKA_VERSION=3.8.7-SNAPSHOT.jar
WEKA_DIST=$PWD/dist/weka-stable-$WEKA_VERSION
DATASET_DIR=wekadocs/data
DATASET_FILE_EXTENSION=arff
STANDARD_CLASS=weka.classifiers.trees.RandomForest
MSU_CLASS=weka.classifiers.trees.RandomForestMSU
CLASS_ARGS="-P 100 -I 100 -num-slots 1 -K 0 -M 1.0 -V 0.001 -S 1"
SCRIPT_DIR=$PWD/cli
WORK_DIR=/var/tmp
LIB_DIR=$PWD/lib/*
USE="msu.sh\n\tDATASET example weather.nominal\n\tDATASET_DIR ../$DATASET_DIR\n\n\tExample: cli/msu.sh weather.nominal ../$DATASET_DIR\n\n--\n\nmsu.sh\n\tDATASET example weather.nominal\n\tDATASET_DIR ../$DATASET_DIR\n\tALGORITHM Tree or Forest, default Tree\n\tWEKA_DIST default $WEKA_DIST\n\tLIB_DIR default $LIB_DIR\n\tSCRIPT_DIR default $SCRIPT_DIR\n\tWORK_DIR default $WORK_DIR\n\n\tExample: cli/msu.sh weather.nominal ../$DATASET_DIR Tree dist/weka-stable-3.8.7-SNAPSHOT.jar lib cli /var/tmp\n"

# Análisis de la línea de comando
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
        STANDARD_OUT=$WORK_DIR/$1.standard.out
        MSU_OUT=$WORK_DIR/$1.msu.out
        OUTPUT_CSV=$WORK_DIR/$1.csv

        if [[ -f $DATASET ]];
        then
            printf "Dataset: %s\n" $DATASET
        else
            printf "Dataset %s not found\n" $DATASET
            exit
        fi        
    else
        echo "Wrong number of parameters"
        echo -e $USE
        exit
    fi
fi

printf "Dataset dir: %s\n" $DATASET_DIR
printf "Standard class: %s\n" $STANDARD_CLASS
printf "MSU class: %s\n\n--\n\n" $MSU_CLASS

# Ejecución de programas
java -cp $WEKA_DIST:$LIB_DIR \
      $STANDARD_CLASS \
      $CLASS_ARGS -t $DATASET \
      > $STANDARD_OUT

java -cp $WEKA_DIST:$LIB_DIR \
      $MSU_CLASS \
      $CLASS_ARGS -t $DATASET \
      > $MSU_OUT

# Filtrado de resultados
read TREE_SIZE INSTANCES SECONDS_TO_BUILD_MODEL CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE KAPPA_STATISTIC MAE RMSE RAE RRSE < \
 <(awk -f $SCRIPT_DIR/weka_results_analyzer.awk $STANDARD_OUT)

read TREE_SIZE_MSU INSTANCES_MSU SECONDS_TO_BUILD_MODEL_MSU CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU KAPPA_STATISTIC_MSU MAE_MSU RMSE_MSU RAE_MSU RRSE_MSU < \
 <(awk -f $SCRIPT_DIR/weka_results_analyzer.awk $MSU_OUT)

# Cálculo de comparativa. Bash no soporta por defecto operaciones con números decimales
SECONDS_TO_BUILD_MODEL_COMP=$(echo "($SECONDS_TO_BUILD_MODEL_MSU-$SECONDS_TO_BUILD_MODEL)"| bc -l)
CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP=$(echo "($CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU - $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE)"| bc -l)
INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP=$(echo "($INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU - $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE)"| bc -l)
KAPPA_STATISTIC_COMP=$(echo "($KAPPA_STATISTIC_MSU - $KAPPA_STATISTIC)"| bc -l)
MAE_COMP=$(echo "($MAE_MSU - $MAE)"| bc -l)
RMSE_COMP=$(echo "($RMSE_MSU - $RMSE)"| bc -l)
RAE_COMP=$(echo "($RAE_MSU - $RAE)"| bc -l)
RRSE_COMP=$(echo "($RRSE_MSU - $RRSE)"| bc -l)

# Conversión necesaria al formato decimal español, ya que el sistema operativo está en castellano y la salida de Weka no está internacionalizada
SECONDS_TO_BUILD_MODEL=$(echo $SECONDS_TO_BUILD_MODEL | sed "s/\./,/")
CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE=$(echo $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE | sed "s/\./,/")
INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE=$(echo $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE | sed "s/\./,/")
KAPPA_STATISTIC=$(echo $KAPPA_STATISTIC | sed "s/\./,/")
MAE=$(echo $MAE | sed "s/\./,/")
RMSE=$(echo $RMSE | sed "s/\./,/")
RAE=$(echo $RAE | sed "s/\./,/")
RRSE=$(echo $RRSE | sed "s/\./,/")

SECONDS_TO_BUILD_MODEL_MSU=$(echo $SECONDS_TO_BUILD_MODEL_MSU | sed "s/\./,/")
CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU=$(echo $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU | sed "s/\./,/")
INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU=$(echo $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU | sed "s/\./,/")
KAPPA_STATISTIC_MSU=$(echo $KAPPA_STATISTIC_MSU | sed "s/\./,/")
MAE_MSU=$(echo $MAE_MSU | sed "s/\./,/")
RMSE_MSU=$(echo $RMSE_MSU | sed "s/\./,/")
RAE_MSU=$(echo $RAE_MSU | sed "s/\./,/")
RRSE_MSU=$(echo $RRSE_MSU | sed "s/\./,/")

SECONDS_TO_BUILD_MODEL_COMP=$(echo $SECONDS_TO_BUILD_MODEL_COMP | sed "s/\./,/")
CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP=$(echo $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP | sed "s/\./,/")
INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP=$(echo $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP | sed "s/\./,/")
KAPPA_STATISTIC_COMP=$(echo $KAPPA_STATISTIC_COMP | sed "s/\./,/")
MAE_COMP=$(echo $MAE_COMP | sed "s/\./,/")
RMSE_COMP=$(echo $RMSE_COMP | sed "s/\./,/")
RAE_COMP=$(echo $RAE_COMP | sed "s/\./,/")
RRSE_COMP=$(echo $RRSE_COMP | sed "s/\./,/")

# Creación CSV de salida
printf "Metric;Standard Version;MSU Version;Comparison MSU-Standard\n" > $OUTPUT_CSV
if [[ $3 = "Tree" ]];
then
    printf "Tree size;%s;%s;%s\n" $TREE_SIZE $TREE_SIZE_MSU $(expr $TREE_SIZE_MSU - $TREE_SIZE) >> $OUTPUT_CSV
fi
printf "Total Number of Instances;%s;%s;%s\n" $INSTANCES $INSTANCES_MSU $(expr $INSTANCES_MSU - $INSTANCES) >> $OUTPUT_CSV
printf "Seconds taken to build model;%f;%f;%f\n" $SECONDS_TO_BUILD_MODEL $SECONDS_TO_BUILD_MODEL_MSU $SECONDS_TO_BUILD_MODEL_COMP >> $OUTPUT_CSV
printf "Correctly classified instances percentaje;%f;%f;%f\n" $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU $CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP >> $OUTPUT_CSV
printf "Incorrectly classified instances percentaje;%f;%f;%f\n" $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_MSU $INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE_COMP >> $OUTPUT_CSV
printf "Kappa statistic;%f;%f;%f\n" $KAPPA_STATISTIC $KAPPA_STATISTIC_MSU $KAPPA_STATISTIC_COMP >> $OUTPUT_CSV
printf "Mean absolute error;%f;%f;%f\n" $MAE $MAE_MSU $MAE_COMP >> $OUTPUT_CSV
printf "Root mean squared error;%f;%f;%f\n" $RMSE $RMSE_MSU $RMSE_COMP >> $OUTPUT_CSV
printf "Relative absolute error;%f;%f;%f\n" $RAE $RAE_MSU $RAE_COMP >> $OUTPUT_CSV
printf "Root relative squared error;%f;%f;%f\n" $RRSE $RRSE_MSU $RRSE_COMP >> $OUTPUT_CSV
printf "\n\n--\n\nComparison CSV %s saved\n" $OUTPUT_CSV