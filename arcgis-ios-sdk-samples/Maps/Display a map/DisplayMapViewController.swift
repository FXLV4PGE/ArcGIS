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

import UIKit
import ArcGIS

class DisplayMapViewController: UIViewController {
    
    @IBOutlet private weak var mapView:AGSMapView!
    
    
    private var graphicsOverlay = AGSGraphicsOverlay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize map with a basemap
        let map = AGSMap(basemap: AGSBasemap.imagery())
        
        //assign the map to the map view
        self.mapView.map = map
        self.mapView.touchDelegate = self  // •Ric

        
        
        //add the source code button item to the right of navigation bar
        (self.navigationItem.rightBarButtonItem as! SourceCodeBarButtonItem).filenames = ["DisplayMapViewController"]
    }
    
    private func createPolyline() -> AGSPolyline {
        //create a polyline
        let polylineBuilder = AGSPolylineBuilder(spatialReference: AGSSpatialReference.wgs84())
        polylineBuilder.addPointWith(x: -119.992, y: 41.989)
        polylineBuilder.addPointWith(x: -119.994, y: 38.994)
        polylineBuilder.addPointWith(x: -114.620, y: 35.0)
        
        return polylineBuilder.toGeometry()
    }

   // --------------------------------------------------------------------------------------------------
    // MARK: Private methods
    
    func overlaydrawing() {
        print(#function)
        self.mapView.graphicsOverlays.add(self.graphicsOverlay)
        let buoyMarker = AGSSimpleMarkerSymbol(style: AGSSimpleMarkerSymbolStyle.circle, color: UIColor.red, size: 10)
        let lineSymbol = AGSSimpleLineSymbol(style: AGSSimpleLineSymbolStyle.dash,
                                             color: UIColor(red: 0.5, green: 0, blue: 0.5, alpha: 1),
                                             width: 4)
        
        self.graphicsOverlay.graphics.add(AGSGraphic(geometry: self.createPolyline(), symbol: lineSymbol, attributes: nil))
        graphicsOverlay.selectionColor = UIColor.red
       // graphicsOverlay.graphics.add(lineSymbol)
        
    }
    // --------------------------------------------------------------------------------------------------
    // MARK: - Action methods
    
    @IBAction func drawSomethingAction(_ sender: UIBarButtonItem) {
        overlaydrawing()
        print("Draw Something")
    }
    
    @IBAction func removeAction(_ sender: UIBarButtonItem) {
        print("Remove Action")
    }
    
    @IBAction func exitAction(_ sender: UIBarButtonItem) {
        exit(0)
    }
}

// ==================================================================================================

extension DisplayMapViewController:AGSGeoViewTouchDelegate {
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        //add a feature at the tapped location
        print(#function, ") didTapAtScreenPoint")
    }

}
