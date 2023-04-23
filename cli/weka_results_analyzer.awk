# ---------------------------------------------------------------------------------------------------
# weka_results_analyzer.awk: Analizador de salida de Weka para comparativas. 
#                            Extrae métricas resultado de la ejecución de algorimos de clasificación. 
#
# author: Paco Saucedo.
# ---------------------------------------------------------------------------------------------------

BEGIN {
  VALIDATION_FLAG = false
  DISTINCT_ATTRIBUTES = 0
  BRANCHES_NUMBER = 0
  LEAVES_NUMBER = 0
}

{  
  if (/Distinct attributes:/)
    DISTINCT_ATTRIBUTES = $3 

  if (/Average Distinct Attributes:/)
    DISTINCT_ATTRIBUTES = $4 

  if (/Branches number:/)
    BRANCHES_NUMBER = $3 
 
  if (/Average Branches Number:/)
    BRANCHES_NUMBER = $4 

  if (/Leaves number:/)
    LEAVES_NUMBER = $3 
 
  if (/Average Leaves Number:/)
    LEAVES_NUMBER = $4 
    
  if (/Time taken to build model:/)
    SECONDS_TO_BUILD_MODEL = $6 
    
  if (/Time taken to perform cross-validation:/)
    SECONDS_TO_VALIDATE = $6 
  
  if (/=== Stratified cross-validation ===/)
    VALIDATION_FLAG = true
    
  if (VALIDATION_FLAG == true && /Correctly Classified Instances/)
    CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE = $5
    
  if (VALIDATION_FLAG == true && /Incorrectly Classified Instances/)
    INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE = $5
    
  if (VALIDATION_FLAG == true && /Kappa statistic/)
    KAPPA_STATISTIC = $3
    
  if (VALIDATION_FLAG == true && /Mean absolute error/)
    MAE = $4
    
  if (VALIDATION_FLAG == true && /Root mean squared error/)
    RMSE = $5
    
  if (VALIDATION_FLAG == true && /Relative absolute error/)
    RAE = $4
    
  if (VALIDATION_FLAG == true && /Root relative squared error/)
    RRSE = $5
    
  if (VALIDATION_FLAG == true && /Total Number of Instances/)
    INSTANCES = $5    
}

END {
  print DISTINCT_ATTRIBUTES, BRANCHES_NUMBER, LEAVES_NUMBER, INSTANCES, SECONDS_TO_BUILD_MODEL, SECONDS_TO_VALIDATE, CORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE, INCORRECTLY_CLASSIFIED_INSTANCES_PERCENTAJE, KAPPA_STATISTIC, MAE, RMSE, RAE, RRSE
}
