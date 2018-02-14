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

/// An individual Token
class Token: Codable {

    let name: String
    let symbol: String
    let value: String
    let decimals: Int
    let contractAddress: String
    let icon: String
    fileprivate(set) var canShowFiatValue = false

    lazy var displayValueString: String = {
        let decimalNumberValue = NSDecimalNumber(hexadecimalString: self.value)
        var decimalValueString = decimalNumberValue.stringValue

        let valueFormatter = NumberFormatter()
        valueFormatter.numberStyle = .decimal

        guard self.decimals > 0 else { return decimalValueString }

        var insertionString = ""
        if decimalValueString.length == self.decimals {
            insertionString.append(valueFormatter.zeroSymbol ?? "0")
        }

        insertionString.append(valueFormatter.decimalSeparator ?? ".")

        let insertIndex = decimalValueString.index(decimalValueString.endIndex, offsetBy: -self.decimals)
        decimalValueString.insert(contentsOf: insertionString, at: insertIndex)

        return decimalValueString
    }()

    enum CodingKeys: String, CodingKey {
        case
        name,
        symbol,
        value,
        decimals,
        contractAddress = "contract_address",
        icon
    }

    init(name: String,
         symbol: String,
         value: String,
         decimals: Int,
         contractAddress: String,
         iconPath: String) {
        self.name = name
        self.symbol = symbol
        self.value = value
        self.decimals = decimals
        self.contractAddress = contractAddress
        self.icon = iconPath
    }

    var localIcon: UIImage? {
        return UIImage(named: self.icon)
    }
}

// MARK: - Ether Token

/// A class which uses token to view Ether balances
final class EtherToken: Token {

    let wei: NSDecimalNumber

    init(valueInWei: NSDecimalNumber) {
        wei = valueInWei

        super.init(name: Localized("wallet_ether_name"),
                   symbol: "ETH",
                   value: EthereumConverter.ethereumValueString(forWei: wei, withSymbol: false),
                   decimals: 5,
                   contractAddress: "",
                   iconPath: "ether_logo")
        canShowFiatValue = true
    }

    override var displayValueString: String {
        get {
            return value
        }
        set {
            // do nothing - this is read-only since it's lazy, but the compiler doesn't think so since it's still a var.
        }
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    func convertToFiat() -> String? {
        return EthereumConverter.fiatValueString(forWei: wei, exchangeRate: ExchangeRateClient.exchangeRate)
    }
}

/// Convenience class for decoding an array of Token with the key "tokens"
final class TokenResults: Codable {

    let tokens: [Token]

    enum CodingKeys: String, CodingKey {
        case
        tokens
    }
}

// MARK: - Wallet Item

extension Token: WalletItem {
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return symbol
    }
    
    var iconPath: String? {
        return icon
    }
    
    var details: String? {
        return displayValueString
    }

    var uniqueIdentifier: String {
        return symbol
    }
}