
//  FourImages.swift
//
//

import UIKit
public class FourImages: UIView{
    public var ivs = [UIImageView] ()
    
    public override init (frame: CGRect) {
        super.init (frame: frame)
        ivs.append(UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)))
        ivs.append(UIImageView(frame: CGRect(x: 200, y: 0, width: 200, height: 200)))
        ivs.append(UIImageView(frame: CGRect(x: 0, y: 200, width: 200, height: 200)))
        ivs.append(UIImageView(frame: CGRect(x: 200, y: 200, width: 200, height: 200)))
        for i in 0...3 {
      //      ivs[i].contentMode = .scaleAspectFit
            self.addSubview(ivs[i])
        }

    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
