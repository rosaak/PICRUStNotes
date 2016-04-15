# Picrust run
# CAUTION : use the closed ref gg picked otus in biom json format only
# INPUT : path to biom json file and result directory
# Activate the Picrust source
# Usage : picrust_run.sh closed.biom.json outdir

b2s=biom_to_stamp.py

workon picrustEnv

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  Modify here  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
closed_biom=$1 #input closed ref otuin json file format
resdir=$2 #out dir

echo $closed_biom
echo $resdir

nor_c_biom=$resdir"/normalized_closed.biom"
closed_otu_spf=$resdir"/closed_otu.spf"

kegg_met_pred=$resdir"/kegg_metagenome_prediction.biom"
kegg_met_pred_spf=$resdir"/kegg_metagenome_prediction.spf"
kegg_met_pred_nsti=$resdir"/kegg_metagenome_prediction_NSTI.tab"

ko_l3_collapsed_b=$resdir"/kegg_pathway_predictions.L3.biom"
ko_l3_collapsed_f=$resdir"/kegg_pathway_predictions.L3.txt"
ko_l3_collapsed_spf=$resdir"/kegg_pathway_predictions.L3.spf"

cog_met_pred=$resdir"/cog_metagenome_prediction.biom"
cog_met_pred_spf=$resdir"/cog_metagenome_prediction.spf"
cog_met_pred_nsti=$resdir"/cog_metagenome_prediction_NSTI.tab"

cog_l2_collapsed_b=$resdir"/cog_pathway_predictions.L2.biom"
cog_l2_collapsed_f=$resdir"/cog_pathway_predictions.L2.txt"
cog_l2_collapsed_spf=$resdir"/pathway_predictions.L2.spf"

rfam_met_pred=$resdir"/rfam_metagenome_prediction.biom"
rfam_met_pred_spf=$resdir"/rfam_metagenome_prediction.spf"
rfam_met_pred_nsti=$resdir"/rfam_metagenome_prediction_NSTI.tab"

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

echo "Normalizing data..."

normalize_by_copy_number.py -i $closed_biom -o $nor_c_biom

echo "Predict Metagenome from KEGG, COG and RFAM categories..."
predict_metagenomes.py -a $kegg_met_pred_nsti -i $nor_c_biom -o $kegg_met_pred --with_confidence
predict_metagenomes.py -a $cog_met_pred_nsti -i $nor_c_biom -t cog -o $cog_met_pred --with_confidence
predict_metagenomes.py -a $rfam_met_pred_nsti -i $nor_c_biom -t rfam -o $rfam_met_pred --with_confidence

echo "Collapse the predicted functions into higher categories..." 
categorize_by_function.py -i $kegg_met_pred -c KEGG_Pathways -l 3 -o $ko_l3_collapsed_b
categorize_by_function.py -f -i $kegg_met_pred -c KEGG_Pathways -l 3 -o $ko_l3_collapsed_f

categorize_by_function.py -i $cog_met_pred -c COG_Category -l 2 -o $cog_l2_collapsed_b
categorize_by_function.py -f -i $cog_met_pred -c COG_Category -l 2 -o $cog_l2_collapsed_f

deactivate

workon QiimeVenv

echo  "Converting the outputs to spf format for STAMP..."


$b2s -m taxonomy  $closed_biom > $closed_otu_spf

$b2s -m KEGG_Description $kegg_met_pred > $kegg_met_pred_spf
$b2s -m COG_Category $cog_met_pred > $cog_met_pred_spf

$b2s -m KEGG_Pathways $ko_l3_collapsed_b > $ko_l3_collapsed_spf
$b2s -m COG_Category $cog_l2_collapsed_b > $cog_l2_collapsed_spf

deactivate

echo "Boooom ... done"
