/*
 Copyright © 23/04/2016 Shaps
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit
import GraphicsRenderer

extension UIView {
    
    @objc var horizontalConstraints: [NSLayoutConstraint] {
        return constraintsAffectingLayout(for: .horizontal)
    }
    
    @objc var verticalConstraints: [NSLayoutConstraint] {
        return constraintsAffectingLayout(for: .vertical)
    }
    
    @objc var horizontalContentHuggingPriority: UILayoutPriority {
        return contentHuggingPriority(for: .horizontal)
    }
    
    @objc var verticalContentHuggingPriority: UILayoutPriority {
        return contentHuggingPriority(for: .vertical)
    }
    
    @objc var horizontalContentCompressionResistance: UILayoutPriority {
        return contentCompressionResistancePriority(for: .horizontal)
    }
    
    @objc var verticalContentCompressionResistance: UILayoutPriority {
        return contentCompressionResistancePriority(for: .vertical)
    }
    
    public override func preparePeek(with coordinator: Coordinator) {
        if bounds.size != .zero {
            let image = ImageRenderer(size: bounds.size).image { [weak self] context in
                let rect = context.format.bounds
                self?.drawHierarchy(in: rect, afterScreenUpdates: true)
            }
            
            if image.size != .zero {
                coordinator.appendPreview(image: image, forModel: self)
            }
        }
        
        coordinator.appendDynamic(keyPaths: [
            "backgroundColor",
            "tintColor"
        ], forModel: self, in: .appearance)
        
        coordinator.appendDynamic(keyPaths: [
            "translatesAutoresizingMaskIntoConstraints"
        ], forModel: self, in: .layout)
        
        var current = classForCoder
        coordinator.appendStatic(title: String(describing: current), detail: nil, value: "", in: .classes)
        
        while let next = current.superclass() {
            coordinator.appendStatic(title: String(describing: next), detail: nil, value: "", in: .classes)
            current = next
        }
        
        for view in subviews {
            coordinator.appendStatic(title: String(describing: view.classForCoder), detail: "", value: view, in: .views)
        }
    }
    
    /**
     Configures Peek's properties for this object
     
     - parameter context: The context to apply these properties to
     */
    public override func preparePeek(_ context: Context) {
        super.preparePeek(context)
        
        context.configure(.attributes, "Accessibility") { config in
            config.addProperties(keyPaths: [
                ["accessibilityIdentifier": "Identifier"],
                ["accessibilityHint": "Hint"],
                ["accessibilityPath": "Path"],
                ["accessibilityFrame": "Frame"],
                ["accessibilityLabel": "Label"],
                ["accessibilityValue": "Value"]
            ])
        }
        
        context.configure(.attributes, "General") { config in
            config.addProperties([ "frame", "bounds", "center", "intrinsicContentSize", "alignmentRectInsets" ])
            config.addProperty("translatesAutoresizingMaskIntoConstraints", displayName: "Translates Resize Masks", cellConfiguration: nil)
        }
        
        context.configure(.attributes, "Appearance") { (config) in
            config.addProperty("contentMode", displayName: nil, cellConfiguration: { (cell, _, value) in
                if let mode = UIViewContentMode(rawValue: value as! Int) {
                    cell.detailTextLabel?.text = mode.description
                }
            })
        }
        
        context.configure(.attributes, "Interaction") { config in
            config.addProperties([ "userInteractionEnabled", "multipleTouchEnabled", "exclusiveTouch" ])
        }
        
        context.configure(.attributes, "Color") { config in
            config.addProperties([ "alpha", "backgroundColor", "tintColor" ])
            
            config.addProperty("tintAdjustmentMode", displayName: nil, cellConfiguration: { (cell, _, value) in
                if let mode = UIViewTintAdjustmentMode(rawValue: value as! Int) {
                    cell.detailTextLabel?.text = mode.description
                }
            })
        }
        
        context.configure(.attributes, "Drawing") { config in
            config.addProperties([ "opaque", "hidden", "clipsToBounds" ])
        }
        
        context.configure(.attributes, "General") { config in
            config.addProperties([ "tag", "class", "superclass" ])
        }
        
        context.configure(.attributes, "Layer") { (config) in
            config.addProperties([ "layer.position", "layer.anchorPoint", "layer.zPosition", "layer.geometryFlipped", "layer.anchorPointZ", ])
        }
        
        guard !translatesAutoresizingMaskIntoConstraints else { return }
        
        context.configure(.attributes, "Content Hugging Priority") { (config) in
            config.addProperty("horizontalContentHuggingPriority", displayName: "Horizontal", cellConfiguration: nil)
            config.addProperty("verticalContentHuggingPriority", displayName: "Vertical", cellConfiguration: nil)
        }
        
        context.configure(.attributes, "Content Compression Resistance") { (config) in
            config.addProperty("horizontalContentCompressionResistance", displayName: "Horizontal", cellConfiguration: nil)
            config.addProperty("verticalContentCompressionResistance", displayName: "Vertical", cellConfiguration: nil)
        }
        
        context.configure(.attributes, "Constraints") { (config) in
            config.addProperty("horizontalConstraints", displayName: "Horizontal", cellConfiguration: nil)
            config.addProperty("verticalConstraints", displayName: "Vertical", cellConfiguration: nil)
            config.addProperties(["hasAmbiguousLayout"])
        }
    }
    
}
