//
//  UIColor+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

extension UIColor {
    
    static func colorBy(language: String) -> UIColor? {
        
        switch language {

            case "Swift":        return #colorLiteral(red: 0.9409505129, green: 0.3160626292, blue: 0.2198818624, alpha: 1)
            case "Objective-C":  return #colorLiteral(red: 0.2625062168, green: 0.5574804544, blue: 0.9995576739, alpha: 1)
            case "Kotlin":       return #colorLiteral(red: 0.6619448662, green: 0.4826087356, blue: 0.999563992, alpha: 1)
            case "C":            return #colorLiteral(red: 0.3331416845, green: 0.3331416845, blue: 0.3331416249, alpha: 1)
            case "C++":          return #colorLiteral(red: 0.9514692426, green: 0.2945584357, blue: 0.4915213585, alpha: 1)
            case "C#":           return #colorLiteral(red: 0.09259193391, green: 0.5235601068, blue: 0.003201843007, alpha: 1)
            case "Python":       return #colorLiteral(red: 0.2082129419, green: 0.4469336271, blue: 0.647174418, alpha: 1)
            case "JavaScript":   return #colorLiteral(red: 0.9449369907, green: 0.8797165751, blue: 0.3514455259, alpha: 1)
            case "Java":         return #colorLiteral(red: 0.6912410259, green: 0.4459078908, blue: 0.09978499264, alpha: 1)
            case "HTML":         return #colorLiteral(red: 0.8919278979, green: 0.2985142767, blue: 0.1494699121, alpha: 1)
            case "Ruby":         return #colorLiteral(red: 0.9409505129, green: 0.3160626292, blue: 0.2198818624, alpha: 1)
            case "Shell":        return #colorLiteral(red: 0.5389230847, green: 0.8794205785, blue: 0.3175361753, alpha: 1)
            case "PHP":          return #colorLiteral(red: 0.3106755614, green: 0.3659948111, blue: 0.5835784078, alpha: 1)

        default: return nil
        }
    }
}
