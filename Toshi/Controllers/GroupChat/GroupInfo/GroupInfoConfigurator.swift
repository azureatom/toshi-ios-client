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

import Foundation
import UIKit

final class GroupInfoConfigurator: CellConfigurator {

    override func configureCell(_ cell: UITableViewCell, with cellData: TableCellData) {
        guard let cell = cell as? BasicTableViewCell else { return }

        cell.titleTextField.text = cellData.title

        cell.subtitleLabel.text = cellData.subtitle
        cell.detailsLabel.text = cellData.details
        cell.leftImageView.image = cellData.leftImage

        if let leftImagePath = cellData.leftImagePath {
            AvatarManager.shared.avatar(for: leftImagePath, completion: { image, path in
                if leftImagePath == path {
                    cell.leftImageView.image = image
                }
            })
        }

        cell.switchControl.isOn = (cellData.switchState == true)

        guard let tag = cellData.tag, let itemType = GroupItemType(rawValue: tag) else { return }

        switch itemType {
        case .participant:
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        case .addParticipant:
            cell.titleTextField.textColor = Theme.tintColor
        case .avatarTitle:
            cell.titleTextField.isUserInteractionEnabled = true
            cell.titleTextField.returnKeyType = .done
        case .exitGroup:
            cell.titleTextField.textAlignment = .center
            cell.titleTextField.textColor = Theme.errorColor
        default:
            break
        }
    }
}
