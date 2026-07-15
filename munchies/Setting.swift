//
//  Setting.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/15/26.
//

class Setting: Codable
{
    let title:String
    var switchState:Bool?
    
    init(_ title:String, _ switchState:Bool? = nil)
    {
        self.title = title
        self.switchState = switchState
    }
}
