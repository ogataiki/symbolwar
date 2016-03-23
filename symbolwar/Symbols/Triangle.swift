import SpriteKit

class Triangle: Symbol {

    override init() {
        super.init();
        
        type = .triangle;
        image_name = Symbol.getSymbolName(type);
        sprite = SKSpriteNode(imageNamed: image_name);
        
        attack_target_list = ["ff", "bl", "br"];
        initParam();
        updateParamSprite();
    }
}