import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var player: SKSpriteNode!
    var background: SKSpriteNode!
    var canDoubleJump = false
    var lastTouchPosition: CGPoint?
    var isOnGround = false
    var gameStarted = false

    var platformSpeed: CGFloat = 100
    var treasureCategory: UInt32 = 0x1 << 1
    var platformCategory: UInt32 = 0x1 << 2
    var playerCategory: UInt32 = 0x1 << 3
    
    var coinCount = 0
    var chestCount = 0

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        physicsWorld.contactDelegate = self

        addBackground()
        setupPlayer()
        spawnInitialPlatforms()
        startSpawningPlatforms()
        startSpawningTreasures()
    }

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
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.contactTestBitMask = platformCategory | treasureCategory
        player.physicsBody?.isDynamic = false // Игрок пока не падает
        addChild(player)
    }

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
        treasure.physicsBody?.collisionBitMask = 0 // Это предотвратит отталкивание
        treasure.physicsBody?.contactTestBitMask = playerCategory // Будет регистрировать контакты только с игроком
        treasure.name = (imageName == "coinImage") ? "coin" : "chest"
        addChild(treasure)
    }

    func spawnInitialPlatforms() {
        for i in 0..<5 {
            let y = CGFloat(i) * 220 + 220
            let x = Bool.random() ? 50 : size.width - 50
            spawnPlatform(at: CGPoint(x: x, y: y))
        }
    }

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

    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node == player || node == background { continue }  // Не трогаем фон
            node.position.y -= platformSpeed * CGFloat(deltaTime)
            if node.position.y < -50 {
                node.removeFromParent()
            }
        }

        if let lastTouch = lastTouchPosition {
            let dx = lastTouch.x - player.position.x
            player.physicsBody?.velocity.dx = dx * 2
        }

        if player.position.y < -50 {
            let texture = view?.texture(from: self)
            let image = texture?.cgImage()
            
            let gameOverScene = GameOverScene(size: size)
            gameOverScene.backgroundImage = image
            gameOverScene.coinCount = coinCount
            gameOverScene.chestCount = chestCount
            let transition = SKTransition.fade(withDuration: 1.0)
            view?.presentScene(gameOverScene, transition: transition)
        }

    }

    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    override func didSimulatePhysics() {
        let currentTime = CACurrentMediaTime()
        deltaTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
    }

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

    func didBegin(_ contact: SKPhysicsContact) {
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
        
        // Проверка касания платформы
        if (contact.bodyA.categoryBitMask == platformCategory && contact.bodyB.categoryBitMask == playerCategory) ||
            (contact.bodyB.categoryBitMask == platformCategory && contact.bodyA.categoryBitMask == playerCategory) {
            isOnGround = true
            canDoubleJump = true
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == platformCategory && contact.bodyB.categoryBitMask == playerCategory) ||
            (contact.bodyB.categoryBitMask == platformCategory && contact.bodyA.categoryBitMask == playerCategory) {
            isOnGround = false
        }
    }
}
