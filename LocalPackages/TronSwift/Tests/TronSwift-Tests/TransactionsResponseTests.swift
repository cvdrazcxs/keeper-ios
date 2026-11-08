import Foundation
import Testing
@testable import TronSwiftAPI

@Suite
struct TransactionsResponseTests {
    @Test
    func transactionsResponseDecodesApprovalTransactionType() throws {
        let json = """
        {
          "data": [
            {
              "transaction_id": "transfer-id",
              "token_info": {
                "symbol": "USDT",
                "address": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
                "decimals": 6,
                "name": "Tether USD"
              },
              "block_timestamp": 1773698433000,
              "from": "TU1r33n75FL5dShBt13xcJfgBLuahLgTZo",
              "to": "TKoUnkRBggFPbbsPnXqdnbjfVzRhDfnhoc",
              "type": "Transfer",
              "value": "10000"
            },
            {
              "transaction_id": "approval-id",
              "token_info": {
                "symbol": "USDT",
                "address": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
                "decimals": 6,
                "name": "Tether USD"
              },
              "block_timestamp": 1745606445000,
              "from": "TV6dyPMUAhMbw7E6uXg8DjyG8LX8fSwjah",
              "to": "TU1r33n75FL5dShBt13xcJfgBLuahLgTZo",
              "type": "Approval",
              "value": "10000000"
            }
          ],
          "success": true,
          "meta": {
            "at": 1773753635430,
            "fingerprint": "fingerprint",
            "links": {
              "next": "https://api.trongrid.io/next"
            }
          }
        }
        """

        let response = try JSONDecoder().decode(
            TransactionsResponse.self,
            from: Data(json.utf8)
        )

        #expect(response.success)
        #expect(response.data.count == 2)
        #expect(response.data[0].type == .transfer)
        #expect(response.data[1].type == .approval)
        #expect(response.next == "https://api.trongrid.io/next")
        #expect(response.fingerprint == "fingerprint")
    }
}
