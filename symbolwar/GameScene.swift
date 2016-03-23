import SpriteKit

class GameScene: SKScene {
    
    // 5*8の盤面
    var columns: Int = 5;
    var rows: Int = 8;
    var fields: [Field] = [
        Field(r:0, c:0), Field(r:0, c:1), Field(r:0, c:2), Field(r:0, c:3), Field(r:0, c:4),
        Field(r:1, c:0), Field(r:1, c:1), Field(r:1, c:2), Field(r:1, c:3), Field(r:1, c:4),
        Field(r:2, c:0), Field(r:2, c:1), Field(r:2, c:2), Field(r:2, c:3), Field(r:2, c:4),
        Field(r:3, c:0), Field(r:3, c:1), Field(r:3, c:2), Field(r:3, c:3), Field(r:3, c:4),
        Field(r:4, c:0), Field(r:4, c:1), Field(r:4, c:2), Field(r:4, c:3), Field(r:4, c:4),
        Field(r:5, c:0), Field(r:5, c:1), Field(r:5, c:2), Field(r:5, c:3), Field(r:5, c:4),
        Field(r:6, c:0), Field(r:6, c:1), Field(r:6, c:2), Field(r:6, c:3), Field(r:6, c:4),
        Field(r:7, c:0), Field(r:7, c:1), Field(r:7, c:2), Field(r:7, c:3), Field(r:7, c:4),
    ];
    func getFieldsIndex(rc: (r:Int, c:Int)) -> Int {
        return (rc.r * columns) + rc.c;
    }
    func getFieldsRC(index: Int) -> (r: Int, c: Int) {
        return (index/columns, index%columns);
    }
    func getFieldsPosition(rc: (r:Int, c:Int)) -> CGPoint {
        return fields[getFieldsIndex(rc)].sprite.position;
    }
    func getFieldsPosition(index: Int) -> CGPoint {
        return fields[index].sprite.position;
    }
    
    var view_center = CGPointZero;
    
    var player_hp = 10;
    var enemy_hp = 10;
    
    let deck_count = 4;
    let operation_max = 2;
    var operation_count = 0;

    var player_fields: [Field] = [Field(r:-1, c:-1), Field(r:-1, c:-1), Field(r:-1, c:-1), Field(r:-1, c:-1)];
    var enemy_fields: [Field] = [Field(r:-1, c:-1), Field(r:-1, c:-1), Field(r:-1, c:-1), Field(r:-1, c:-1)];
    
    var player_deck: [Symbol?] = [nil, nil, nil, nil];
    var enemy_deck: [Symbol?] = [nil, nil, nil, nil];
    
    enum SCENE_STATUS: Int {
        case preparation = 0
        case hand_out_pre_effect
        case hand_out
        case hand_out_fin_effect
        case operation
        case enemy_operation
        case refill
        case pre_effect
        case move_symbol
        case attack_symbol
        case fin_effect
        case result
    }
    var scene_sts = SCENE_STATUS.preparation;
    func chgSceneSts(sts: SCENE_STATUS) {
        scene_sts = sts;
        
        // 状態遷移時の初期化処理
        switch sts {
        case .operation:
            operation_count = 0;
            this_turn_deploy_symbols = [:];
        default:
            break;
        }
    }
    
    var turn: Int = 0;
    
    struct DEPLOY_SYMBOL {
        var player: Bool;
        var enemy: Bool;
        var symbol: Symbol;
    }
    var this_turn_deploy_symbols: [Int: DEPLOY_SYMBOL] = [:];
    var field_symbols: [Int: [Int: DEPLOY_SYMBOL]] = [:];
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // 手札抽選準備
        let keys = symbol_lottery.keys;
        for key in keys {
            symbol_lottery_total += symbol_lottery[key]!;
        }

        settingFields();
        
        settingPlayerFields();
        settingEnemyFields();
        
        chgSceneSts(.hand_out_pre_effect);
    }
    
    func settingFields() {
        fields[0].setPlayerField(0);
        fields[1].setPlayerField(1);
        fields[2].setPlayerField(2);
        fields[3].setPlayerField(3);
        fields[4].setPlayerField(4);
        fields[(columns * rows) - 5].setEnemyField();
        fields[(columns * rows) - 4].setEnemyField();
        fields[(columns * rows) - 3].setEnemyField();
        fields[(columns * rows) - 2].setEnemyField();
        fields[(columns * rows) - 1].setEnemyField();
        
        for i in 0 ..< fields.count {
            let field = fields[i];
            
            self.addChild(field.sprite);
            
            let s: CGFloat = Field.size;
            let base_x = self.view!.center.x - (s*CGFloat(columns/2));
            let base_y = self.view!.center.y - (s*CGFloat(rows/2)) + (s/2);
            field.sprite.position = CGPoint(x: base_x+(s*CGFloat(field.column)), y: base_y+(s*CGFloat(field.row)));
            
            if field.row % 2 == 0 && field.player_field == false {
                field.sprite.color = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0);
            }
            else if field.player_field == false && field.enemy_field == false {
                field.sprite.color = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0);
            }
        }
    }
    
    func settingPlayerFields() {
        
        let s: CGFloat = Field.size;
        let base_x = self.view!.center.x - (s*CGFloat(player_fields.count/2)) + (s/2);
        let base_y = self.view!.center.y - (s*CGFloat(rows/2)) - (s/2);
        
        for i in 0 ..< player_fields.count {
            let field = player_fields[i];
            field.setPlayerField(-1);
            field.sprite.blendMode = SKBlendMode.Add;
            field.sprite.position = CGPoint(x: base_x+(s*CGFloat(i)), y: base_y);
            self.addChild(field.sprite);
        }
    }
    
    func settingEnemyFields() {
        
        let s: CGFloat = Field.size;
        let base_x = self.view!.center.x - (s*CGFloat(enemy_fields.count/2)) + (s/2);
        let base_y = self.view!.center.y + (s*CGFloat(rows/2)) + (s/2);
        
        for i in 0 ..< enemy_fields.count {
            let field = enemy_fields[i];
            field.setEnemyField();
            field.sprite.blendMode = SKBlendMode.Add;
            field.sprite.position = CGPoint(x: base_x+(s*CGFloat(i)), y: base_y);
            self.addChild(field.sprite);
        }
    }
    
    func handOut() {
        // ゲーム開始時に手札を配る
        chgSceneSts(SCENE_STATUS.hand_out);

        // 最初は全部揃っている
        
        player_deck[0] = Triangle();
        player_deck[1] = Square();
        player_deck[2] = Star();
        player_deck[3] = Circle();
        for i in 0 ..< player_deck.count {
            player_deck[i]!.setPlayerMode();
        }

        enemy_deck[0] = Triangle();
        enemy_deck[1] = Square();
        enemy_deck[2] = Star();
        enemy_deck[3] = Circle();
        for i in 0 ..< enemy_deck.count {
            enemy_deck[i]!.setEnemyMode();
        }
        
        updateDeck();
    }
    
    func refill() {
        for i in 0 ..< deck_count {
            if player_deck[i] == nil {
                player_deck[i] = lotterySymbol();
                player_deck[i]!.setPlayerMode();
            }
            if enemy_deck[i] == nil {
                enemy_deck[i] = lotterySymbol();
                enemy_deck[i]!.setEnemyMode();
            }
        }
        
        updateDeck();
        
        // 足りない手札を補充する
        chgSceneSts(SCENE_STATUS.refill);
    }
    
    var symbol_lottery: [Symbol.SYMBOL_TYPE : Int] = [
        Symbol.SYMBOL_TYPE.triangle: 100,
        Symbol.SYMBOL_TYPE.square: 100,
        Symbol.SYMBOL_TYPE.star: 20,
        Symbol.SYMBOL_TYPE.circle: 30,
    ];
    var symbol_lottery_total = 0;
    func lotterySymbol() -> Symbol {
        let keys = symbol_lottery.keys;
        var total = 0;
        let hit = Int(arc4random_uniform(UInt32(symbol_lottery_total)));
        var result = Symbol.SYMBOL_TYPE.triangle;
        for key in keys {
            total += symbol_lottery[key]!;
            if hit <= total {
                result = key;
                break;
            }
        }
        switch result {
        case .triangle: return Triangle();
        case .square: return Square();
        case .star: return Star();
        case .circle: return Circle();
        }
    }
    
    func updateDeck() {
        // デッキ内容を手札フィールドに反映
        for i in 0 ..< deck_count {
            if let symbol = player_deck[i] {
                if player_fields[i].symbol == nil {
                    player_fields[i].symbol = symbol;
                    self.addChild(symbol.sprite);
                    symbol.sprite.name = "\(i)";
                    symbol.sprite.position = player_fields[i].sprite.position;
                }
            }
            if let symbol = enemy_deck[i] {
                if enemy_fields[i].symbol == nil {
                    enemy_fields[i].symbol = symbol;
                    self.addChild(symbol.sprite);
                    symbol.sprite.position = enemy_fields[i].sprite.position;
                }
            }
        }
    }
    
    struct PICK_NODE {
        var symbol: Symbol;
        var pdeck_index: Int;
    }
    var pick_node: [UITouch:PICK_NODE] = [:];
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        switch scene_sts {
        case .operation:
            // シンボルの操作を許可
            for touch in touches {
                let location = touch.locationInNode(self)
                let node = self.nodeAtPoint(location);
                if let n = node.name {
                    let index = Int(n);
                    if let pdeck_index = index {
                        if let deck = player_deck[pdeck_index] {
                            pick_node[touch] = PICK_NODE(symbol: deck, pdeck_index: pdeck_index);
                            break;
                        }
                    }
                }
            }
            break;
            
        default:
            break;
        }

    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        switch scene_sts {
        case .operation:
            // シンボルの操作を許可
            
            for touch in touches {
                if let node = pick_node[touch] {
                    let location = touch.locationInNode(self)
                    node.symbol.sprite.position = location;
                }
            }
            break;
            
        default:
            break;
        }

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        switch scene_sts {
        case .operation:
            // シンボルの操作を許可
            
            for touch in touches {
                if let node = pick_node[touch] {
                    var moved = false;
                    let location = touch.locationInNode(self);
                    let tnodes = self.nodesAtPoint(location);
                    for field in tnodes {
                        if let fname = field.name {
                            for i in 0 ..< columns {
                                if fname == "player_field\(i)" {
                                    
                                    fields[i].symbol = node.symbol;
                                    node.symbol.sprite.position = field.position;
                                    node.symbol.deploy_turn = turn;
                                    node.symbol.deploy_index = operation_count;
                                    node.symbol.rc = (r:0, c:i);
                                    
                                    this_turn_deploy_symbols[operation_count] = DEPLOY_SYMBOL(player: true, enemy: false, symbol: node.symbol);
                                    
                                    player_deck[node.pdeck_index] = nil;
                                    player_fields[node.pdeck_index].symbol = nil;
                                    
                                    operation_count += 1;
                                    moved = true;
                                }
                            }
                        }
                    }
                    
                    if moved == false {
                        node.symbol.sprite.position = player_fields[node.pdeck_index].sprite.position;
                    }
                }
                pick_node.removeValueForKey(touch);
            }
            
            if operation_count >= operation_max {
                chgSceneSts(.enemy_operation);
            }
            break;
            
        default:
            break;
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        let keys = pick_node.keys;
        for key in keys {
            let node = pick_node[key]!;
            node.symbol.sprite.position = player_fields[node.pdeck_index].sprite.position;
        }
        pick_node = [:];
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        switch scene_sts {
        case .preparation:          updatePreparation();
        case .hand_out_pre_effect:  updateHandOutPreEffect();
        case .hand_out:             updateHandOut();
        case .hand_out_fin_effect:  updateHandOutFinEffect();
        case .operation:            updateOperation();
        case .enemy_operation:      updateEnemyOperation();
        case .refill:               updateRefill();
        case .pre_effect:           updatePreEffect();
        case .move_symbol:          updateMoveSymbol();
        case .attack_symbol:        updateAttackSymbol();
        case .fin_effect:           updateFinEffect();
        case .result:               updateResult();
        }
    }
    
    func updatePreparation() {
        // 処理なし
    }
    
    func updateHandOutPreEffect() {
        // TODO:とりあえず次へ
        handOut();
    }
    
    func updateHandOut() {
        // TODO:本来は演出を入れる
        chgSceneSts(.hand_out_fin_effect);
    }
    
    func updateHandOutFinEffect() {
        chgSceneSts(.operation);
    }
    
    func updateOperation() {
        // 操作待ち
    }
    
    func updateEnemyOperation() {
        
        // TODO:AIを後で用意
        var field_buf: [Int] = [0, 1, 2, 3, 4];
        var deck_buf: [Int] = [0, 1, 2, 3];
        
        for _ in 0 ..< operation_max {
            let findex = Int(arc4random_uniform(UInt32(field_buf.count)));
            let dindex = Int(arc4random_uniform(UInt32(deck_buf.count)));
            
            let target_field = fields[(columns * rows) - field_buf[findex] - 1];
            target_field.symbol = enemy_deck[deck_buf[dindex]]!;
            target_field.symbol!.sprite.position = target_field.sprite.position;
            target_field.symbol!.deploy_turn = turn;
            target_field.symbol!.deploy_index = operation_count;
            target_field.symbol!.rc = (r:target_field.row, c:target_field.column);
            
            this_turn_deploy_symbols[operation_count] = DEPLOY_SYMBOL(player: false, enemy: true, symbol: target_field.symbol!);
            
            enemy_deck[deck_buf[dindex]] = nil;
            enemy_fields[deck_buf[dindex]].symbol = nil;
            
            field_buf.removeAtIndex(findex);
            deck_buf.removeAtIndex(dindex);
            
            operation_count += 1;
        }
        
        field_symbols[turn] = this_turn_deploy_symbols;
        
        chgSceneSts(.pre_effect);
    }
    
    func updatePreEffect() {
        // TODO:移動開始演出入れる
        
        updateMoveSymbol_Start();
    }
    
    struct MOVE_SYMBOL_LOG {
        var symbol: Symbol;
        var fromRow: Int;
        var toRow: Int;
    }
    var move_log: [MOVE_SYMBOL_LOG] = [];
    var move_finish: Int = 0;
    var move_total: Int = 0;
    func updateMoveSymbol_Start() {
        move_log = [];
        move_finish = 0;
        move_total = 0;
        for t in field_symbols.keys {
            var i = 0;
            for op in field_symbols[t]!.keys {
                let deploy_symbol = field_symbols[t]![op]!;
                let beforRow: Int = deploy_symbol.symbol.rc.r;
                var nextRow: Int;
                if deploy_symbol.player && deploy_symbol.enemy == false {
                    nextRow = deploy_symbol.symbol.rc.r+2;
                    if nextRow >= rows {
                        nextRow = rows-1;
                    }
                }
                else if deploy_symbol.enemy && deploy_symbol.player == false {
                    nextRow = deploy_symbol.symbol.rc.r-2;
                    if nextRow < 0 {
                        nextRow = 0;
                    }
                }
                else { continue; } // 移動しない
                
                move_total += 1;
                
                move_log.append(MOVE_SYMBOL_LOG(symbol: deploy_symbol.symbol, fromRow:beforRow, toRow: nextRow));
                deploy_symbol.symbol.rc = (r:nextRow, c:deploy_symbol.symbol.rc.c);
                
                fields[getFieldsIndex((r:nextRow, c:deploy_symbol.symbol.rc.c))].symbol = deploy_symbol.symbol;
                fields[getFieldsIndex((r:beforRow, c:deploy_symbol.symbol.rc.c))].symbol = nil;
                
                let wait = SKAction.waitForDuration(0.4*NSTimeInterval(t)+0.2*NSTimeInterval(i));
                let moveto = SKAction.moveTo(getFieldsPosition((r:nextRow, c:deploy_symbol.symbol.rc.c)), duration: 0.4);
                let endf = SKAction.runBlock({ 
                    print("move end \(nextRow),\(deploy_symbol.symbol.rc.c)");
                })
                deploy_symbol.symbol.sprite.runAction(SKAction.sequence([wait, moveto, endf]), completion: {
                    self.move_finish += 1;
                    print("move_finish");
                });
                
                i += 1;
            }
        }
        chgSceneSts(.move_symbol);
    }
    func updateMoveSymbol() {
        // 先に配置した図形(field_symbolsの順)に移動を処理する
        if move_finish >= move_total {
            print(" --- attack start ---");
            updateAttackSymbol_Start();
        }
    }
    
    struct ATTACK_LOG {
        var attacker_symbol: Symbol;
        var victim_symbol: Symbol;
    }
    var attack_logs: [Int: ATTACK_LOG] = [:];
    var attack_finish: Int = 0;
    var attack_effect_duration = 0.05;
    func updateAttackSymbol_Start() {
        // アタックログの生成とアニメーション開始
        let target_pos_list: [String: (r:Int, c:Int)] = [
            "fl" : (r:1, c:-1), "ff" : (r:1, c:0), "fr" : (r:1, c:1),
            "bl" : (r:-1, c:-1), "bb" : (r:-1, c:0), "br" : (r:-1, c:1)
        ];
        attack_finish = 0;
        attack_logs = [:];
        var attack_index = 0;
        for t in field_symbols.keys {
            for op in field_symbols[t]!.keys {
                let attacker_symbol = field_symbols[t]![op]!;
                for tkey in target_pos_list.keys {
                    if let is_attack = attacker_symbol.symbol.attack_target[tkey] {
                        if is_attack == false {
                            print("continue out of target");
                            continue;
                        }
                    }
                    let target = target_pos_list[tkey]!;
                    let target_pos: (r:Int, c:Int);
                    if attacker_symbol.player {
                        target_pos = (attacker_symbol.symbol.rc.r + target.r, attacker_symbol.symbol.rc.c + target.c);
                    }
                    else {
                        target_pos = (attacker_symbol.symbol.rc.r + (target.r*(-1)), attacker_symbol.symbol.rc.c + (target.c*(-1)));
                    }
                    print("\(#function) target_pos:\(target_pos)");
                    // 範囲外と図形なしをチェック
                    if (target_pos.r < 0 || target_pos.r >= rows) || (target_pos.c < 0 || target_pos.c >= columns) {
                        print("continue out of range");
                        continue;
                    }
                    if fields[getFieldsIndex(target_pos)].symbol == nil {
                        print("continue no symbol");
                        continue;
                    }
                    print("hit!");
                    let victim = fields[getFieldsIndex(target_pos)].symbol!;
                    
                    // 自軍攻撃をしないようチェック
                    var is_attack_ok = false;
                    if attacker_symbol.player && attacker_symbol.enemy == false && victim.player == false && victim.enemy {
                        is_attack_ok = true;
                    }
                    else if attacker_symbol.enemy && attacker_symbol.player == false && victim.enemy == false && victim.player {
                        is_attack_ok = true;
                    }
                    else { print("\(#function) symbol error attacker:\(attacker_symbol.symbol.rc) or victim:\(victim.rc) ?"); continue; } // バグってる。処理しない。
                    
                
                    if is_attack_ok {

                        attack_logs[attack_logs.count] = ATTACK_LOG(attacker_symbol: attacker_symbol.symbol, victim_symbol: victim);
                        
                        //アニメーション開始しちゃう
                        var sequence: [SKAction] = [];
                        sequence.append(SKAction.waitForDuration(4.0 * NSTimeInterval(attack_index)));
                        sequence.append(SKAction.sequence([
                            SKAction.fadeAlphaTo(0.1, duration: attack_effect_duration), SKAction.fadeAlphaTo(1.0, duration: attack_effect_duration),
                            SKAction.fadeAlphaTo(0.1, duration: attack_effect_duration), SKAction.fadeAlphaTo(1.0, duration: attack_effect_duration),
                            SKAction.fadeAlphaTo(0.1, duration: attack_effect_duration), SKAction.fadeAlphaTo(1.0, duration: attack_effect_duration),
                            ])
                        );
                        sequence.append(SKAction.waitForDuration(0.5));
                        sequence.append(SKAction.runBlock({
                            self.attackFieldFlashing(victim, victim: true);
                        }));
                        sequence.append(SKAction.waitForDuration(0.8));
                        sequence.append(SKAction.runBlock({
                            self.victimDamage(victim);
                        }, queue: dispatch_get_main_queue()));
                        // カウンターありの場合
                        if victim.counter {
                            sequence.append(SKAction.waitForDuration(0.3));
                            sequence.append(SKAction.runBlock({
                                self.victimDamage(attacker_symbol.symbol);
                                }, queue: dispatch_get_main_queue())
                            );
                        }
                        sequence.append(SKAction.waitForDuration(1.5));
                        attacker_symbol.symbol.sprite.runAction(
                            SKAction.sequence(sequence),
                            completion: {
                                self.attack_finish += 1;
                            }
                        );
                        
                        attack_index += 1;
                    }
                }
            }
        }

        chgSceneSts(.attack_symbol);
    }
    func attackFieldFlashing(symbol: Symbol, victim: Bool) {
        // 攻撃側と被害側の背景を点滅させる
        let sprite = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: Symbol.size, height: Symbol.size));
        sprite.position = symbol.sprite.position;
        sprite.alpha = 0.3;
        
        let tint_color: UIColor;
        if victim {
            tint_color = UIColor.redColor();
        }
        else {
            tint_color = UIColor.greenColor();
        }
        let tint = SKAction.colorizeWithColor(tint_color, colorBlendFactor: 1.0, duration: attack_effect_duration);
        let tint_clr = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 1.0, duration: attack_effect_duration);
        
        addChild(sprite);
        sprite.runAction(SKAction.sequence([
            tint, tint_clr,
            tint, tint_clr,
            tint, tint_clr
            ]), completion: {
                sprite.removeFromParent();
        });
    }
    func victimDamage(victim: Symbol) -> Void {
        
        let flashing = SKAction.sequence([
            SKAction.fadeAlphaTo(0.1, duration: attack_effect_duration), SKAction.fadeAlphaTo(1.0, duration: attack_effect_duration),
            SKAction.fadeAlphaTo(0.1, duration: attack_effect_duration), SKAction.fadeAlphaTo(1.0, duration: attack_effect_duration),
            SKAction.fadeAlphaTo(0.1, duration: attack_effect_duration), SKAction.fadeAlphaTo(1.0, duration: attack_effect_duration),
            ]);
        
        victim.sprite.runAction(SKAction.sequence([flashing]), completion: {
            let damage_label = SKLabelNode(text: "-1");
            damage_label.fontSize = 14.0;
            damage_label.fontColor = UIColor.redColor();
            damage_label.position = victim.sprite.position;
            self.addChild(damage_label);
            
            let move = SKAction.moveToY(victim.sprite.position.y + 10, duration: 1.0);
            damage_label.runAction(SKAction.sequence([move, flashing]), completion: {
                damage_label.removeFromParent();
                
                // 実際のダメージ
                victim.param.hp -= 1;
            });
        });
    }
    func dieSymbol() {
        for t in field_symbols.keys {
            for i in field_symbols[t]!.keys {
                let symbol = field_symbols[t]![i]!.symbol;
                if symbol.param.hp <= 0 {
                    // 消失
                    fields[getFieldsIndex(symbol.rc)].symbol = nil;
                    field_symbols[symbol.deploy_turn]!.removeValueForKey(symbol.deploy_index);
                    if field_symbols[symbol.deploy_turn]!.count == 0 {
                        field_symbols.removeValueForKey(symbol.deploy_turn);
                    }
                    symbol.sprite.removeFromParent();
                }
            }
        }
    }
    
    func updateAttackSymbol() {
        // アタック終了の判定
        if attack_finish >= attack_logs.count {
            dieSymbol();
            chgSceneSts(.fin_effect);
        }
    }
    
    func updateFinEffect() {
        turn += 1;
        
        let winner = judgeWinner();
        if winner.player && winner.enemy  {
            // 引き分け
            print("引き分け");
            chgSceneSts(.result);
            return;
        }
        else if winner.player && winner.enemy == false {
            // 勝利
            print("勝ち");
            chgSceneSts(.result);
            return;
        }
        else if winner.enemy && winner.player == false {
            // 敗北
            print("負け");
            chgSceneSts(.result);
            return;
        }
        
        
        refill();
    }
    
    func judgeWinner() -> (player: Bool, enemy: Bool) {
        
        var winner: (player: Bool, enemy:Bool) = (false, false);
        
        for i in 0 ..< columns {
            if fields[i].symbol != nil && fields[i].symbol!.enemy {
                player_hp -= fields[i].symbol!.param.atk;
                print("player lastHP:\(player_hp)");
            }
        }
        
        for i in fields.count - columns ..< fields.count {
            if fields[i].symbol != nil && fields[i].symbol!.player {
                enemy_hp -= fields[i].symbol!.param.atk;
                print("enemy lastHP:\(enemy_hp)");
            }
        }
        
        if player_hp <= 0 {
            winner.enemy = true;
        }
        if enemy_hp <= 0 {
            winner.player = true;
        }
        
        return winner;
    }
    
    func updateRefill() {
        // TODO:配布演出の終了を検知
        chgSceneSts(.operation);
    }
    
    func updateResult() {
        
    }
}
