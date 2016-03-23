import SpriteKit

class Circle: Symbol {
    
    override init() {
        super.init();

        type = .circle;
        image_name = Symbol.getSymbolName(type);
        sprite = SKSpriteNode(imageNamed: image_name);
        
        counter = true;
        initParam();
        updateParamSprite();
    }
}