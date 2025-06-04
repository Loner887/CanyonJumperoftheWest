import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Nodes
    var player: SKSpriteNode!
    var background: SKSpriteNode!
    
    // Game state
    var canDoubleJump = false
    var lastTouchPosition: CGPoint?
    var isOnGround = false
    var gameStarted = false
    
    // Game parameters
    var platformSpeed: CGFloat = 100
    var coinCount = 0
    var chestCount = 0
    
    // Physics categories
    var treasureCategory: UInt32 = 0x1 << 1
    var platformCategory: UInt32 = 0x1 << 2
    var playerCategory: UInt32 = 0x1 << 3
    var rockCategory: UInt32 = 0x1 << 4
    
    // Timers
    var rockTimer: Timer?
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        physicsWorld.contactDelegate = self
        
        addBackground()
        setupPlayer()
        spawnInitialPlatforms()
        startSpawningPlatforms()
        startSpawningTreasures()
        startRockTimer()
    }
    
    // MARK: - Setup Methods
    
    func addBackground() {
        background = SKSpriteNode(imageNamed: "backgroundImage")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = size
        addChild(background)
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "playerImage")
        player.position = CGPoint(x: size.width / 2, y: size.height * 0.9)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.restitution = 0.0
        player.physicsBody?.friction = 0.0
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = platformCategory | rockCategory
        player.physicsBody?.contactTestBitMask = platformCategory | treasureCategory | rockCategory
        player.physicsBody?.isDynamic = false
        addChild(player)
    }
    
    // MARK: - Spawning Methods
    
    func spawnPlatform(at position: CGPoint) {
        let imageName = Bool.random() ? "platformImage" : "widePlatformImage"
        let platform = SKSpriteNode(imageNamed: imageName)
        platform.position = position
        platform.size = CGSize(width: imageName == "platformImage" ? 100 : 150, height: 20)
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.restitution = 0.0
        platform.physicsBody?.friction = 0.0
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        addChild(platform)
    }
    
    func spawnTreasure(at position: CGPoint) {
        let imageName: String
        if Bool.random() {
            imageName = "coinImage"
        } else {
            imageName = "chestImage"
        }
        let treasure = SKSpriteNode(imageNamed: imageName)
        treasure.position = position
        treasure.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        treasure.physicsBody?.isDynamic = false
        treasure.physicsBody?.categoryBitMask = treasureCategory
        treasure.physicsBody?.collisionBitMask = 0
        treasure.physicsBody?.contactTestBitMask = playerCategory
        treasure.name = (imageName == "coinImage") ? "coin" : "chest"
        addChild(treasure)
    }
    
    func spawnRock() {
        let rock = SKSpriteNode(imageNamed: "rockImage")
        rock.position = CGPoint(x: size.width / 2, y: size.height + 50)
        
        rock.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        rock.physicsBody?.categoryBitMask = rockCategory
        rock.physicsBody?.collisionBitMask = platformCategory | playerCategory
        rock.physicsBody?.contactTestBitMask = playerCategory
        rock.physicsBody?.isDynamic = true
        rock.physicsBody?.affectedByGravity = true
        rock.physicsBody?.restitution = 0.3
        rock.physicsBody?.linearDamping = 0.5
        rock.name = "rock"
        
        // Add some horizontal movement
        let xImpulse = CGFloat.random(in: -50...50)
        rock.physicsBody?.applyImpulse(CGVector(dx: xImpulse, dy: 0))
        
        addChild(rock)
    }
    
    func spawnInitialPlatforms() {
        for i in 0..<5 {
            let y = CGFloat(i) * 220 + 220
            let x = Bool.random() ? 50 : size.width - 50
            spawnPlatform(at: CGPoint(x: x, y: y))
        }
    }
    
    // MARK: - Timer Methods
    
    func startSpawningPlatforms() {
        let spawn = SKAction.run {
            let x = Bool.random() ? 50 : self.size.width - 50
            let y = self.size.height
            self.spawnPlatform(at: CGPoint(x: x, y: y))
        }
        let delay = SKAction.wait(forDuration: 1.5)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func startSpawningTreasures() {
        let spawn = SKAction.run {
            let x = Bool.random() ? 50 : self.size.width - 50
            let y = self.size.height + 40
            self.spawnTreasure(at: CGPoint(x: x, y: y))
        }
        let delay = SKAction.wait(forDuration: 3.0)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func startRockTimer() {
        rockTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 3...4), repeats: true) { [weak self] _ in
            self?.spawnRock()
            self?.rockTimer?.invalidate()
            self?.startRockTimer()
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            gameStarted = true
            player.physicsBody?.isDynamic = true
        }
        
        if let touch = touches.first {
            lastTouchPosition = touch.location(in: self)
        }
        
        if isOnGround {
            player.physicsBody?.velocity.dy = 0
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
            isOnGround = false
        } else if canDoubleJump {
            player.physicsBody?.velocity.dy = 0
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
            canDoubleJump = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastTouchPosition = touch.location(in: self)
        }
    }
    
    // MARK: - Physics Contact
    
    func didBegin(_ contact: SKPhysicsContact) {
        // Treasure collection
        if (contact.bodyA.categoryBitMask == treasureCategory || contact.bodyB.categoryBitMask == treasureCategory) {
            if let treasure = contact.bodyA.categoryBitMask == treasureCategory ? contact.bodyA.node : contact.bodyB.node {
                if treasure.name == "coin" {
                    coinCount += 1
                } else if treasure.name == "chest" {
                    chestCount += 1
                }
                treasure.removeFromParent()
            }
        }
        
        // Platform contact
        if (contact.bodyA.categoryBitMask == platformCategory && contact.bodyB.categoryBitMask == playerCategory) ||
            (contact.bodyB.categoryBitMask == platformCategory && contact.bodyA.categoryBitMask == playerCategory) {
            isOnGround = true
            canDoubleJump = true
        }
        
        // Rock hit
        if (contact.bodyA.categoryBitMask == rockCategory && contact.bodyB.categoryBitMask == playerCategory) ||
           (contact.bodyB.categoryBitMask == rockCategory && contact.bodyA.categoryBitMask == playerCategory) {
            playerHitByRock()
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == platformCategory && contact.bodyB.categoryBitMask == playerCategory) ||
            (contact.bodyB.categoryBitMask == platformCategory && contact.bodyA.categoryBitMask == playerCategory) {
            isOnGround = false
        }
    }
    
    func playerHitByRock() {
        // Knockback effect
        player.physicsBody?.applyImpulse(CGVector(dx: CGFloat.random(in: -100...100), dy: -50))
        
        // Visual feedback
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0.0, duration: 0.1)
        ])
        player.run(flashAction)
    }
    
    // MARK: - Update Loop
    
    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        deltaTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
        
        // Move all nodes down (except player and background)
        for node in children {
            if node == player || node == background { continue }
            node.position.y -= platformSpeed * CGFloat(deltaTime)
            
            // Remove nodes that are off screen
            if node.position.y < -100 {
                node.removeFromParent()
            }
        }
        
        // Player movement
        if let lastTouch = lastTouchPosition {
            let dx = lastTouch.x - player.position.x
            player.physicsBody?.velocity.dx = dx * 2
        }
        
        // Game over check
        if player.position.y < -50 {
            gameOver()
        }
    }
    
    func gameOver() {
        let texture = view?.texture(from: self)
        let image = texture?.cgImage()
        
        let gameOverScene = GameOverScene(size: size)
        gameOverScene.backgroundImage = image
        gameOverScene.coinCount = coinCount
        gameOverScene.chestCount = chestCount
        let transition = SKTransition.fade(withDuration: 1.0)
        view?.presentScene(gameOverScene, transition: transition)
    }
    
    deinit {
        rockTimer?.invalidate()
    }
}
