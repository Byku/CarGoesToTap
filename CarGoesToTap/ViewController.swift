import UIKit

struct Constants {
    static let carWidth: CGFloat = 50
    static let carLength: CGFloat = 100
    static let turningRadius: CGFloat = 70
    static let colors: [UIColor] = [.yellow, .red, .blue, .black, .gray, .green, .orange]
}

class ViewController: UIViewController {
    private var car: Car!
    private var gesture: UITapGestureRecognizer!
    
    private var tapPosition: (x: CGFloat, y: CGFloat) = (0, 0) {
        didSet {
            view.removeGestureRecognizer(gesture)
            carMoving()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let carXPosition = (view.frame.width - Constants.carWidth) * 0.5
        let carYPosition = view.frame.height - Constants.carLength
        car = Car(at: Position(x: carXPosition, y: carYPosition), orientation: .top)
        car.backgroundColor = .yellow
        view.addSubview(car)
        
        gesture = UITapGestureRecognizer(target: self, action:  #selector (self.viewTapped (_:)))
        view.addGestureRecognizer(gesture)
    }
}

private extension ViewController {
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: car)
            if car.point(inside: point, with: nil) {
                car.backgroundColor = Constants.colors[Int.random(in: 0..<7)]
            } else {
                tapPosition = (sender.location(in: view).x, sender.location(in: view).y)
            }
        }
    }
    
    func carMoving() {
        guard let moveStep = car.makeDecisionToNextStep(finishPoint: tapPosition) else {
            moveFinished()
            return
        }
        switch moveStep {
        case let .move(distance):
            car.move(for: distance) { [unowned self] in
                self.carMoving()
            }
        case let .turn(turnDirection):
            car.turn(to: turnDirection) {
                self.carMoving()
            }
        }
    }
    
    func moveFinished() {
        view.addGestureRecognizer(gesture)
    }
}
