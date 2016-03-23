import SpriteKit

class Circle: Symbol {
    
    override init() {
        super.init();

        counter = true;
        
        param_base = PARAM(hp:2, atk:attack_target_list.count);
        param = param_base;

        image_name = Symbol.getSymbolName(.circle);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}