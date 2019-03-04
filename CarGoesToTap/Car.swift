import UIKit

enum CarOrientation {
    case top
    case right
    case left
    case down
}

enum TurnType {
    case right
    case left
}

enum MovingType {
    case move(CGFloat)
    case turn(TurnType)
}

struct Position {
    var x: CGFloat
    var y: CGFloat
}

class Car: UIView {
    var orientation: CarOrientation
    
    init(at position: Position, orientation: CarOrientation = .top) {
        self.orientation = orientation
        super.init(frame: CGRect(x: position.x,
                                 y: position.y,
                                 width: Constants.carWidth,
                                 height: Constants.carLength))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var position: Position {
        get {
            switch self.orientation {
            case .top:
                return Position(x: frame.midX, y: frame.midY)
            case .down:
                return Position(x: frame.midX, y: frame.midY)
            case .left:
                return Position(x: frame.midX, y: frame.midY)
            case .right:
                return Position(x: frame.midX, y: frame.midY)
            }
        }
    }
    
    var movingDirectionMultiplier: CGFloat {
        get {
            switch self.orientation {
            case .down, .right:
                return 1
            case .top, .left:
                return -1
            }
        }
    }
    
    func needToMove(to destination: (x: CGFloat, y: CGFloat)) -> Bool {
        let deltaX = destination.x - position.x
        let deltaY = destination.y - position.y
        let minMove = Constants.turningRadius
        if abs(deltaX) <= minMove && abs(deltaY) <= minMove {
            return false
        }
        
        return true
    }
    
    func makeDecisionToNextStep(finishPoint destination: (x: CGFloat, y: CGFloat)) -> MovingType? {
        let deltaX = destination.x - position.x
        let deltaY = destination.y - position.y
        let minMove = Constants.turningRadius
        
        guard needToMove(to: destination) else { return nil }
        
        // проверяем, куда направлена пипка чтобы подъехать ближе или повернуться в нужную сторону
        switch orientation {
        case .top where deltaY < -minMove,
             .down where deltaY > minMove:
            return .move(abs(deltaY) - minMove)
        case .left where deltaX < -minMove,
             .right where deltaX > minMove:
            return .move(abs(deltaX) - minMove)
        case .top where deltaY >= -minMove:
            return deltaX < 0 ? .turn(.left) : .turn(.right)
        case .down where deltaY <= minMove:
            return deltaX < 0 ? .turn(.right) : .turn(.left)
        case .left where deltaX >= -minMove:
            return deltaY < 0 ? .turn(.right) : .turn(.left)
        case .right where deltaX <= minMove:
            return deltaY < 0 ? .turn(.left) : .turn(.right)
        default:
            return nil
        }
    }
    
    func move(for distance: CGFloat, completion: @escaping () -> ()) {
        let multiplier = movingDirectionMultiplier
        
        UIView.animate(withDuration: 1, animations: { [unowned self] in
            switch self.orientation {
            case .top, .down:
                self.frame.origin.y += multiplier * distance
            case .left, .right:
                self.frame.origin.x += multiplier * distance
            }
        }) { _ in
            completion()
        }
    }
    
    func turn(to turnDirection: TurnType, completion: @escaping () -> ()) {
        var turnMovingY: CGFloat
        var turnMovingX: CGFloat
        var angle: CGFloat {
            if case .left = turnDirection {
                return -.pi / 2
            }
            return .pi / 2
        }
        var curveX: UIView.AnimationCurve
        var curveY: UIView.AnimationCurve
        
        switch (orientation, turnDirection) {
        case (.top, .right):
            turnMovingY = -Constants.turningRadius
            turnMovingX = Constants.turningRadius
            orientation = .right
        case (.right, .right):
            turnMovingY = Constants.turningRadius
            turnMovingX = Constants.turningRadius
            orientation = .down
        case (.down, .right):
            turnMovingY = Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            orientation = .left
        case (.left, .right):
            turnMovingY = -Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            orientation = .top
        case (.top, .left):
            turnMovingY = -Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            orientation = .left
        case (.right, .left):
            turnMovingY = -Constants.turningRadius
            turnMovingX = Constants.turningRadius
            orientation = .top
        case (.down, .left):
            turnMovingY = Constants.turningRadius
            turnMovingX = Constants.turningRadius
            orientation = .right
        case (.left, .left):
            turnMovingY = Constants.turningRadius
            turnMovingX = -Constants.turningRadius
            orientation = .down
        }
        
        switch orientation {
        case .down, .top:
            curveX = .easeOut
            curveY = .linear
        case .left, .right:
            curveX = .linear
            curveY = .easeOut
        }
        
        
        let animationY = UIViewPropertyAnimator(duration: 1, curve: curveY) {
            self.frame.origin.y += turnMovingY
        }
        
        let animationX = UIViewPropertyAnimator(duration: 1, curve: curveX) {
            self.frame.origin.x += turnMovingX
        }
        
        let animationRotate = UIViewPropertyAnimator(duration: 0.9, curve: .linear) {
            self.transform = self.transform.rotated(by: angle)
        }
        
        animationRotate.addCompletion { _ in
            completion()
        }
        
        animationY.startAnimation()
        animationX.startAnimation()
        animationRotate.startAnimation()
    }
    
}
