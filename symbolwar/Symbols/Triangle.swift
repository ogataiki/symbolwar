import SpriteKit

class Triangle: Symbol {

    override init() {
        super.init();
        
        attack_target_list = ["ff", "bl", "br"];
        for s in attack_target_list {
            attack_target[s] = true;
        }
        
        param_base = PARAM(hp:2, atk:attack_target_list.count);
        param = param_base;

        image_name = Symbol.getSymbolName(.triangle);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}