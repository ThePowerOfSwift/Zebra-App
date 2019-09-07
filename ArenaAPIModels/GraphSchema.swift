//
//  GraphSchema.swift
//  ArenaAPIModels
//
//  Created by Firas Rafislam on 16/07/19.
//  Copyright © 2019 Firas Rafislam. All rights reserved.
//

import Foundation

public enum Directions {
    case ASC
    case DESC
}

public enum Sorts {
    case CREATED_AT
    case POSITION
    case UPDATED_AT
}

public enum Query {
    
    public enum Blocks {
        case page
        case per
        
        public enum Directions {
            case ASC
            case DESC
        }
        
        public enum Sorts {
            case CREATED_AT
            case POSITION
            case POSITION_AT
        }
        
        
    }
}
