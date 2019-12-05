from qgis.core import *
from PyQt5.QtCore import *

# This is necessary for the processing to work ### Otherwise get "algorithm not found" error
from qgis.analysis import QgsNativeAlgorithms

import sys
import os

QgsApplication.setPrefixPath("/usr",True)

# Starts the application, with False to not launch the GUI
app = QgsApplication([], False)

app.initQgis()

sys.path.append('/usr/share/qgis/python/plugins')

# Import and initialize Processing framework
from processing.core.Processing import Processing
import processing

Processing.initialize()
QgsApplication.processingRegistry().addProvider(QgsNativeAlgorithms())

# Read config file
import configparser
config = configparser.ConfigParser()
config.read('config.ini')
atlas_dataset = config['DEFAULT']['Atlas-Dataset'] # exact file path
shapefile = config['DEFAULT']['Shapefile'] # exact file path of shape file
output_file = config['DEFAULT']['Output-File']

# This is the actual QGIS part of the script and it works as a python script in the QGIS GUI
uri = 'file://{}?d?delimiter=,type=csv&detectTypes=yes&xField=longtitude&yField=latitude&crs=EPSG:4326&spatialIndex=no&subsetIndex=no&watchFile=no'.format(atlas_dataset)
layer_csv = QgsVectorLayer(uri,'somename','delimitedtext')
if not layer_csv.isValid():
    print('atlas dataset failed to load')

uri2 = shapefile
overlay_er = QgsVectorLayer(uri2,'somename2','ogr')
if not overlay_er.isValid():
    print('sa2 shapefile layer failed to load')

params = {
'INPUT_FIELDS' : [],\
'OUTPUT' : output_file,\
'OVERLAY' : overlay_er,\
'OVERLAY_FIELDS' : ['SA2_MAIN16','SA2_5DIG16','SA2_NAME16'],\
'INPUT' : layer_csv}

processing.run("native:intersection",params)

app.exitQgis()
