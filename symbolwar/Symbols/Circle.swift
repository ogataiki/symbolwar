import SpriteKit

class Circle: Symbol {
    
    override init() {
        super.init();

        counter = true;
        
        param_base = PARAM(hp:2, atk:0);
        param = param_base;

        image_name = Symbol.getSymbolName(.circle);
        sprite = SKSpriteNode(imageNamed: image_name);
    }
}