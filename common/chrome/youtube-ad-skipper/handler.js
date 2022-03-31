{
  // ******************************************************************************
  // Chrome 用拡張機能 - YouTube Ad Skipper
  // ******************************************************************************


  // -----------------------------------------------------------------------------
  // オーバーレイ型の広告を非表示にする
  // -----------------------------------------------------------------------------

  const suppressTarget = [
    '.ytp-ad-overlay-container', /* オーバーレイ型広告 */
    '.yt-mealbar-promo-renderer', /* プロモーション情報 */
    '.ytd-banner-promo-renderer',  /* プロモーション情報 */
    '.ytd-reel-shelf-renderer', /* 動画以外のセクション */
    '.ytd-rich-section-renderer', /* 動画以外のセクション */
    '.ytd-merch-shelf-renderer', /* グッズ情報 */
    '.ytd-rich-shelf-renderer', /* トップニュース */
    '.ytd-statement-banner-renderer', /* Premium の案内 */
    '.ytd-companion-slot-renderer', /* 関連動画一覧内の広告 */
    '.ytd-ad-slot-renderer', /* ホーム画面グリッド内の広告 */
    '.ytp-ce-element', /* 終了画面（関連動画とチャンネルロゴ） */
    '.ytp-ce-video', /* 終了画面（関連動画とチャンネルロゴの枠） */
    '.ytp-button[data-title-no-tooltip="次へ"]', /* コントロールバーの [次へ]　ボタン */
    '.ytp-button[data-title-no-tooltip="ミニプレーヤー"]', /* コントロールバーの [ミニプレーヤー]　ボタン */
    '#sponsor-button', /* 動画メニューの [メンバーになる]　ボタン */
    '.ytd-menu-service-item-download-renderer', /* 動画メニューの [オフライン]　ボタン */
    'ytd-button-renderer:has([aria-label="共有"])', /* 動画メニューの [共有]　ボタン */
    'ytd-button-renderer:has([aria-label="オフライン"])', /* 動画メニューの [オフライン]　ボタン */
    'ytd-button-renderer:has([aria-label="Thanks"])', /* 動画メニューの [Thanks]　ボタン */
    'ytd-button-renderer:has([aria-label="クリップ"])', /* 動画メニューの [クリップ]　ボタン */
    'ytd-button-renderer:has([aria-label="報告"])', /* 動画メニューの [報告]　ボタン */
    'ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"]', /* スポンサー広告*/
  ];
  const overrideStyle = document.createElement('style');
  overrideStyle.innerText = suppressTarget.concat('').join('{display:none!important;}');
  document.getElementsByTagName('head').item(0).appendChild(overrideStyle);

  // -----------------------------------------------------------------------------
  // 動画型広告の終了時に自動スキップする
  // -----------------------------------------------------------------------------

  /**
   * 「広告をスキップ」ボタンを押下するメソッド
   */
  const performClickAdSkip = () => {
    const adSkipClassName = "ytp-ad-skip-button-container";
    document.getElementsByClassName(adSkipClassName)[0]?.click();
  };

  // オブザーバーを生成する
  // このオブザーバーはノードの増減を監視し、「広告をスキップ」のオーバーレイが追加されたらボタンを押下する
  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      const overlayClassName = 'ytp-ad-player-overlay';
      if (mutation.addedNodes.length && mutation.addedNodes[0].className === overlayClassName) {
        performClickAdSkip();
      }
    });
  });

  // 監視対象のプレイヤーが生成されていればオブザーバーを実行する
  // そうでない場合は明示的に「広告をスキップ」ボタンを押下する
  // 処理の実行タイミングとプレイヤーの生成タイミングは不定のため、両方に対応する
  const interval = setInterval(() => {
    const observerTargetId = "ytd-player";
    if (document.getElementById(observerTargetId) === null) {
      performClickAdSkip();
      return;
    }

    const observerTarget = document.getElementById(observerTargetId);
    observer.observe(observerTarget, { childList: true, subtree: true });
    clearInterval(interval);
  }, 1000);
};
