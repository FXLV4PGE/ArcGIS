// Copyright 2016 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// --------------------------------------------------------------------------------------------------

import UIKit
import ArcGIS
import Foundation

enum SketchItem:Int {
    case Doodle = 0
    case Polyline
    func desc() -> String {
        switch self {
        case .Doodle:
            return "doodle"
            
        case .Polyline:
            return "polyline"
        }
    }
}

// ==================================================================================================

class SketchViewController: UIViewController {
    
    @IBOutlet private weak var mapView:AGSMapView!
    @IBOutlet private weak var geometrySegmentedControl:UISegmentedControl!
    @IBOutlet private weak var undoBBI:UIBarButtonItem!
    @IBOutlet private weak var redoBBI:UIBarButtonItem!
    @IBOutlet private weak var clearBBI:UIBarButtonItem!
    
    
    private var map:AGSMap!
    private var sketchEditor:AGSSketchEditor!
    
    private var graphicsOverlay = AGSGraphicsOverlay()
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add the source code button item to the right of navigation bar
        (navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["SketchViewController"]
        
        map = AGSMap(basemap: AGSBasemap.lightGrayCanvas())
        
        sketchEditor = AGSSketchEditor()
        mapView.sketchEditor =  sketchEditor
        
        sketchEditor.start(with: nil, creationMode: .polyline)
        
        mapView.map = map
        mapView.interactionOptions.isMagnifierEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(SketchViewController.respondToGeomChanged), name: NSNotification.Name.AGSSketchEditorGeometryDidChange, object: nil)
        
        //set initial viewpoint
        map.initialViewpoint = AGSViewpoint(targetExtent: AGSEnvelope(xMin: -10049589.670344, yMin: 3480099.843772, xMax: -10010071.251113, yMax: 3512023.489701, spatialReference: AGSSpatialReference.webMercator()))
    }
    
    // --------------------------------------------------------------------------------------------------
    // Storing the doodle (free-form sketch) into peristent storage (NSUserDefaults):
    
    func storeSketch(doodle:AGSPolyline) {
        var key = SketchItem.Polyline.desc()
        let polylineJSON = (try? doodle.toJSON()) as? NSDictionary
        key = SketchItem.Doodle.desc()
        UserDefaults.standard.set(polylineJSON, forKey: key)
    }
    
    
    // --------------------------------------------------------------------------------------------------
    
    func respondToGeomChanged() {
        //Enable/disable UI elements appropriately
        undoBBI.isEnabled = sketchEditor.undoManager.canUndo
        redoBBI.isEnabled = sketchEditor.undoManager.canRedo
        clearBBI.isEnabled = sketchEditor.geometry != nil && !sketchEditor.geometry!.isEmpty || self.mapView.graphicsOverlays.contains(graphicsOverlay)
    }
    
    // --------------------------------------------------------------------------------------------------
    //MARK: - Actions
    
    @IBAction func geometryValueChanged(_ segmentedControl:UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:     // point
            sketchEditor.start(with: nil, creationMode: .point)
            
        case 1:     // polyline (doodle)
            sketchEditor.start(with: nil, creationMode: .freehandPolyline)
            
        case 2:     // polygon
            sketchEditor.start(with: nil, creationMode: .polygon)
            
        case 3:     // ...redraw
            let lineSymbol = AGSSimpleLineSymbol(style: .solid, color: UIColor.red, width: 3)
            if let storedDoodle = UserDefaults.standard.value(forKey: SketchItem.Doodle.desc()) {
                let doodle = (try? AGSPolygon.fromJSON(storedDoodle)) as! AGSPolyline
                graphicsOverlay.graphics.add(AGSGraphic(geometry: doodle, symbol: lineSymbol, attributes: nil))
                mapView.graphicsOverlays.add(graphicsOverlay)
                clearBBI.isEnabled = true
            }
            
        default:
            break
        }
        
        mapView.sketchEditor = sketchEditor
    }
    
    // --------------------------------------------------------------------------------------------------
    
    @IBAction func undo() {
        if sketchEditor.undoManager.canUndo { //extra check, just to be sure
            sketchEditor.undoManager.undo()
        }
    }
    
    // --------------------------------------------------------------------------------------------------
    
    @IBAction func redo() {
        if sketchEditor.undoManager.canRedo { //extra check, just to be sure
            sketchEditor.undoManager.redo()
        }
    }
    
    // --------------------------------------------------------------------------------------------------
    
    @IBAction func clear() {
        let myPolyLine = sketchEditor.geometry! as? AGSPolyline
        
        if !myPolyLine!.isEmpty {
            storeSketch(doodle:myPolyLine!)
            sketchEditor.clearGeometry()
        }
        
        if self.mapView.graphicsOverlays.contains(graphicsOverlay) {
            self.mapView.graphicsOverlays.remove(graphicsOverlay)
        }
    }
}
