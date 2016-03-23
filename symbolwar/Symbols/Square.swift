import SpriteKit

class Square: Symbol {
    
    override init() {
        super.init();
        
        attack_target_list = ["fl", "fr", "bl", "br"];
        for s in attack_target_list {
            attack_target[s] = true;
        }
        
        param_base = PARAM(hp:2, atk:attack_target_list.count);
        param = param_base;

        image_name = Symbol.getSymbolName(.square);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}