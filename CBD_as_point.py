from qgis.core import QgsProcessing
from qgis.core import QgsProcessingAlgorithm
from qgis.core import QgsProcessingMultiStepFeedback
from qgis.core import QgsProcessingParameterFeatureSource
from qgis.core import QgsProcessingParameterFeatureSink
import processing


class DistanceAndDirectionFromPoint(QgsProcessingAlgorithm):

    def initAlgorithm(self, config=None):
        self.addParameter(QgsProcessingParameterFeatureSource('citycenter', 'City Center', types=[QgsProcessing.TypeVectorAnyGeometry], defaultValue=None))
        self.addParameter(QgsProcessingParameterFeatureSink('Cbd_as_point', 'CBD_as_point', type=QgsProcessing.TypeVectorPoint, createByDefault=True, defaultValue=None))

    def processAlgorithm(self, parameters, context, model_feedback):
        # Use a multi-step feedback, so that individual child algorithm progress reports are adjusted for the
        # overall progress through the model
        feedback = QgsProcessingMultiStepFeedback(2, model_feedback)
        results = {}
        outputs = {}

        # Centroids
        alg_params = {
            'ALL_PARTS': False,
            'INPUT': parameters['citycenter'],
            'OUTPUT': QgsProcessing.TEMPORARY_OUTPUT
        }
        outputs['Centroids'] = processing.run('native:centroids', alg_params, context=context, feedback=feedback, is_child_algorithm=True)

        feedback.setCurrentStep(1)
        if feedback.isCanceled():
            return {}

        # Mean coordinate(s)
        alg_params = {
            'INPUT': outputs['Centroids']['OUTPUT'],
            'UID': None,
            'WEIGHT': None,
            'OUTPUT': parameters['Cbd_as_point']
        }
        outputs['MeanCoordinates'] = processing.run('native:meancoordinates', alg_params, context=context, feedback=feedback, is_child_algorithm=True)
        results['Cbd_as_point'] = outputs['MeanCoordinates']['OUTPUT']
        return results

    def name(self):
        return 'Distance and Direction from Point'

    def displayName(self):
        return 'Distance and Direction from Point'

    def group(self):
        return 'Middlebury'

    def groupId(self):
        return 'Middlebury'

    def shortHelpString(self):
        return """<html><body><h2>Algorithm description</h2>
<p>Can find direction and distance from a central business district to surrounding tracts.</p>
<h2>Input parameters</h2>
<h3>City Center</h3>
<p>The business district in the model. Can be any shape.</p>
<h3>CBD_as_point</h3>
<p></p>
<h2>Outputs</h2>
<h3>CBD_as_point</h3>
<p></p>
<br><p align="right">Algorithm author: Casey Lilley & GEOG0323 at Middlebury</p></body></html>"""

    def createInstance(self):
        return DistanceAndDirectionFromPoint()
