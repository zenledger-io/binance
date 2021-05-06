module Binance
  module Client
    class REST
      ENDPOINTS = {
        # Public API Endpoints
        ping:              'v1/ping',
        time:              'v1/time',
        exchange_info:     'v1/exchangeInfo',
        depth:             'v1/depth',
        trades:            'v1/trades',
        historical_trades: 'v1/historicalTrades',
        agg_trades:        'v1/aggTrades',
        klines:            'v1/klines',
        twenty_four_hour:  'v1/ticker/24hr',
        price:             'v3/ticker/price',
        book_ticker:       'v3/ticker/bookTicker',

        # Account API Endpoints
        order:            'v3/order',
        test_order:       'v3/order/test',
        open_orders:      'v3/openOrders',
        all_orders:       'v3/allOrders',
        account:          'v3/account',
        my_trades:        'v3/myTrades',
        user_data_stream: 'v1/userDataStream',

        # Withdraw API Endpoints
        withdraw:         'v1/capital/withdraw/apply',
        deposit_history:  'v1/capital/deposit/hisrec',
        withdraw_history: 'v1/capital/withdraw/history',
        deposit_address:  'v1/capital/deposit/address',
        account_status:   'v1/account/status',
        system_status:    'v1/system/status',
        withdraw_fee:     'v1/assetDetail.html',
        dust_log:         'v1/userAssetDribbletLog.html',
        dividend_log:     'v1/asset/assetDividend'
      }.freeze
    end
  end
end
