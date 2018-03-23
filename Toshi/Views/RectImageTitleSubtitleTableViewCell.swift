// Copyright (c) 2018 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import UIKit

final class RectImageTitleSubtitleTableViewCell: UITableViewCell {

    var imageViewPath: String? {
        didSet {
            retrieveAvatar()
        }
    }

    lazy var sectionSeparator: UIView = {
        let customSeparator = UIView()
        customSeparator.backgroundColor = Theme.borderColor
        customSeparator.alpha = 0

        return customSeparator
    }()

    lazy var customSeparator: UIView = {
        let customSeparator = UIView()
        customSeparator.backgroundColor = Theme.borderColor
        customSeparator.alpha = 0

        return customSeparator
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Theme.preferredProTextSemibold()
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        return titleLabel
    }()

    lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()

        subtitleLabel.font = Theme.preferredFootnote()
        subtitleLabel.textColor = Theme.lightGreyTextColor
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        subtitleLabel.numberOfLines = 2

        return subtitleLabel
    }()

    lazy var leftImageView: UIImageView = {
        let leftImageView = UIImageView()
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true

        return leftImageView
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        addSubviewsAndConstraints()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        leftImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        sectionSeparator.alpha = 0
        customSeparator.alpha = 0

        leftImageView.layer.cornerRadius = 0
    }

    private func addSubviewsAndConstraints() {
        contentView.addSubview(customSeparator)
        customSeparator.bottom(to: contentView)
        customSeparator.left(to: contentView, offset: 100)
        customSeparator.right(to: contentView, offset: -.largeInterItemSpacing)
        customSeparator.height(CGFloat.lineHeight)
        contentView.addSubview(sectionSeparator)
        
        sectionSeparator.edgesToSuperview(excluding: .top)
        sectionSeparator.height(CGFloat.lineHeight)

        contentView.addSubview(leftImageView)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading

        contentView.addSubview(stackView)

        stackView.centerYToSuperview()
        stackView.leftToRight(of: leftImageView, offset: BasicTableViewCell.interItemMargin, priority: .required)
        stackView.right(to: contentView, offset: -BasicTableViewCell.horizontalMargin, priority: .required)

        titleLabel.height(22)
        stackView.addArrangedSubview(titleLabel)
        stackView.addSpacing(3, after: titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        setupLeftImageView()
    }

    private func setupLeftImageView() {
        leftImageView.top(to: contentView, offset: BasicTableViewCell.imageMargin)
        leftImageView.bottom(to: contentView, offset: -BasicTableViewCell.imageMargin)
        leftImageView.size(CGSize(width: 72, height: 72))
        leftImageView.left(to: contentView, offset: BasicTableViewCell.horizontalMargin)
    }

    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        titleLabel.font = Theme.preferredProTextSemibold()
        subtitleLabel.font = Theme.preferredRegularSmall()
    }

    private func retrieveAvatar() {
        guard let path = imageViewPath else { return }

        AvatarManager.shared.avatar(for: path) { [weak self] image, downloadedImagePath in

            guard let path = self?.imageViewPath else { return }

            if downloadedImagePath == path {
                self?.leftImageView.image = image
            }
        }
    }
}
