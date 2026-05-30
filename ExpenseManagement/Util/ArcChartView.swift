//
//  ArcChartView.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import UIKit

final class ArcChartView: UIView {

    private var slices: [ReportCategorySliceViewData] = []
    private var shapeLayers: [CAShapeLayer] = []
    
    private let centerStack = UIStackView()
    private let totalTitleLabel = UILabel()
    private let totalValueLabel = UILabel()

    var lineWidth: CGFloat = 22

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupCenterLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        setupCenterLabels()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        redrawChart()
    }

    func configure(with slices: [ReportCategorySliceViewData], totalText: String) {
        self.slices = slices
        totalValueLabel.text = totalText
        redrawChart()
    }

    private func setupCenterLabels() {
        centerStack.axis = .vertical
        centerStack.alignment = .center
        centerStack.spacing = 4
        centerStack.translatesAutoresizingMaskIntoConstraints = false

        totalTitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        totalTitleLabel.textColor = .secondaryLabel
        totalTitleLabel.text = "TOTAL"

        totalValueLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        totalValueLabel.textColor = .label

        centerStack.addArrangedSubview(totalTitleLabel)
        centerStack.addArrangedSubview(totalValueLabel)

        addSubview(centerStack)
        NSLayoutConstraint.activate([
            centerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func redrawChart() {
        shapeLayers.forEach { $0.removeFromSuperlayer() }
        shapeLayers.removeAll()

        guard !slices.isEmpty else { return }

        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2

        let totalAmount = slices.reduce(0) { $0 + $1.amount }
        guard totalAmount > 0 else { return }

        var startAngle: CGFloat = -.pi / 2

        for slice in slices {
            let percentage = CGFloat(slice.amount / totalAmount)
            let endAngle = startAngle + percentage * 2 * .pi

            let path = UIBezierPath(
                arcCenter: centerPoint,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )

            let shape = CAShapeLayer()
            shape.path = path.cgPath
            shape.strokeColor = slice.color.cgColor
            shape.lineWidth = lineWidth
            shape.fillColor = UIColor.clear.cgColor
            shape.lineCap = .round

            layer.addSublayer(shape)
            shapeLayers.append(shape)

            animate(shape)

            startAngle = endAngle
        }
    }

    private func animate(_ shape: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        shape.strokeEnd = 1
        shape.add(animation, forKey: "arcAnimation")
    }
}
